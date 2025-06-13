# lease-watcher/watcher.py
import hvac
import requests
import time
import os

VAULT_ADDR = os.getenv('VAULT_ADDR')
WEBHOOK_URL = os.getenv('WEBHOOK_URL')

client = hvac.Client(url=VAULT_ADDR)

def watch_leases():
    known_leases = set()
    while True:
        try:
            leases = client.sys.list_leases('database/creds/')
            for lease_id in leases['data']['keys']:
                if lease_id not in known_leases:
                    trigger_restart(lease_id)
                    known_leases.add(lease_id)
            time.sleep(60)
        except Exception as e:
            print(f"Error watching leases: {str(e)}")
            time.sleep(10)

def trigger_restart(lease_id):
    lease_info = client.sys.read_lease(lease_id)
    meta = lease_info['data']['metadata']
    
    requests.post(
        f"{WEBHOOK_URL}/rotate",
        json={
            "deployment": meta['deployment'],
            "namespace": meta['namespace']
        }
    )

if __name__ == "__main__":
    watch_leases()
