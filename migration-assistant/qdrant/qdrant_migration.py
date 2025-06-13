import sys
import os
import time
import requests

def main(source_url, dest_url):
    tmp_dir = './qdrant_snapshots'
    poll_interval = 5  # seconds
    max_attempts = 60  # 5 minutes

    if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)

    # Get all collections from source
    resp = requests.get(f'{source_url}/collections')
    resp.raise_for_status()
    collections = resp.json().get('result', {}).get('collections', [])
    collection_names = [c['name'] for c in collections]

    for collection in collection_names:
        print(f'Processing collection: {collection}')

        # Check if collection exists at destination and delete if it does
        dest_resp = requests.get(f'{dest_url}/collections/{collection}')
        if dest_resp.status_code == 200:
            print(f'Collection "{collection}" already exists at destination. Deleting it...')
            del_dest_resp = requests.delete(f'{dest_url}/collections/{collection}')
            del_dest_resp.raise_for_status()

        # Step 3.0: Remove existing snapshots on source
        resp = requests.get(f'{source_url}/collections/{collection}/snapshots')
        resp.raise_for_status()
        snapshots = resp.json().get('result', [])
        for snapshot in snapshots:
            snapshot_name = snapshot['name']
            print(f'Deleting existing snapshot: {snapshot_name}')
            del_resp = requests.delete(f'{source_url}/collections/{collection}/snapshots/{snapshot_name}')
            del_resp.raise_for_status()

        # Step 3.1: Create new snapshot (async)
        resp = requests.get(f'{source_url}/collections/{collection}/snapshots')
        resp.raise_for_status()
        snapshots_before = set(s['name'] for s in resp.json().get('result', []))

        create_resp = requests.post(f'{source_url}/collections/{collection}/snapshots', params={'wait': 'false'})
        create_resp.raise_for_status()
        print(f'Snapshot creation response: {create_resp.json()}')

        # Step 3.1: Wait for snapshot creation
        snapshot_name = None
        attempts = 0
        while attempts < max_attempts:
            resp = requests.get(f'{source_url}/collections/{collection}/snapshots')
            resp.raise_for_status()
            snapshots_after = set(s['name'] for s in resp.json().get('result', []))
            new_snapshots = snapshots_after - snapshots_before
            if new_snapshots:
                snapshot_name = new_snapshots.pop()
                break
            time.sleep(poll_interval)
            attempts += 1

        if not snapshot_name:
            print(f'Timeout waiting for snapshot creation for {collection}, skipping...')
            continue

        print(f'Snapshot created: {snapshot_name}')

        # Step 3.2: Download snapshot
        snapshot_path = os.path.join(tmp_dir, snapshot_name)
        with requests.get(f'{source_url}/collections/{collection}/snapshots/{snapshot_name}', stream=True) as r:
            r.raise_for_status()
            with open(snapshot_path, 'wb') as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)
        print(f'Downloaded snapshot to {snapshot_path}')

        is_restored: bool = False
        # Step 3.3: Restore to destination
        with open(snapshot_path, 'rb') as f:
            files = {'snapshot': (snapshot_name, f)}
            upload_resp = requests.post(
                f'{dest_url}/collections/{collection}/snapshots/upload',
                params={'priority': 'snapshot'},
                files=files
            )
            if upload_resp.status_code != 200 or 'result' not in upload_resp.json():
                print(f'Error restoring collection {collection}: {upload_resp.text}')
            elif upload_resp.status_code == 200:
                print(f'Successfully migrated collection: {collection}')
                is_restored = True
            else:
                print(f'Unknown state occurred for {collection} migration')

        # Cleanup
        os.remove(snapshot_path)

        # Cleanup snapshot from destination Qdrant
        del_dest_snap = requests.delete(f'{dest_url}/collections/{collection}/snapshots/{snapshot_name}')
        if del_dest_snap.status_code == 200:
            print(f'Deleted snapshot {snapshot_name} from destination Qdrant')
        else:
            print(f'Warning: could not delete snapshot {snapshot_name} from destination (status {del_dest_snap.status_code})')

    # Remove tmp directory if empty
    if not os.listdir(tmp_dir):
        os.rmdir(tmp_dir)

    print('Migration completed successfully')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: python qdrant_migration.py <source_qdrant_url> <dest_qdrant_url>')
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
