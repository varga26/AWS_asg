import json
import subprocess

out = subprocess.check_output(['aws', 'ec2', 'describe-instances', '--output', 'json'])
d = json.loads(out)
for res in d.get('Reservations', []):
    for inst in res.get('Instances', []):
        state = inst.get('State', {}).get('Name')
        instance_id = inst.get('InstanceId')
        tags = inst.get('Tags', [])
        name = next((t['Value'] for t in tags if t['Key'] == 'Name'), 'Unknown')
        print(f"{instance_id:<20} {state:<15} {name}")
