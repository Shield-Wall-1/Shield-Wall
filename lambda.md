import boto3
import json

ec2_client = boto3.client('ec2')

SECURITY_GROUP_ID = 'your-security-group-id'  # Replace with your actual security group ID

def lambda_handler(event, context):
    try:
        action = event.get('action', 'block')  # Determine if the action is 'block' or 'unblock'
        ip = event['ip']

        if action == 'block':
            block_ip(ip)
        elif action == 'unblock':
            unblock_ip(ip)
        else:
            return {
                'statusCode': 400,
                'body': json.dumps('Invalid action specified')
            }

        return {
            'statusCode': 200,
            'body': json.dumps('IP processed successfully')
        }

    except Exception as e:
        print(f"Error processing log: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error processing log')
        }

def block_ip(ip):
    # This function will no longer add an ingress rule to block the IP.
    # It will only revoke existing rules for this IP if any.

    # Revoke any existing ingress rules for this IP
    try:
        response = ec2_client.revoke_security_group_ingress(
            GroupId=SECURITY_GROUP_ID,
            IpProtocol='-1',
            CidrIp=f'{ip}/32'
        )
        print(f"Revoked ingress rule for IP {ip}: {response}")
    except Exception as e:
        print(f"Error revoking ingress rule for IP {ip}: {str(e)}")

    # The following code is commented out to remove the block IP functionality.
    # Add an ingress rule to block the IP
    # try:
    #     response = ec2_client.authorize_security_group_ingress(
    #         GroupId=SECURITY_GROUP_ID,
    #         IpPermissions=[
    #             {
    #                 'IpProtocol': 'tcp',
    #                 'FromPort': 22,
    #                 'ToPort': 22,
    #                 'IpRanges': [{'CidrIp': f'{ip}/32'}]
    #             }
    #         ]
    #     )
    #     print(f"Added ingress rule to block IP {ip}: {response}")
    # except Exception as e:
    #     print(f"Error adding ingress rule to block IP {ip}: {str(e)}")

def unblock_ip(ip):
    # Revoke the ingress rule to unblock the IP
    try:
        response = ec2_client.revoke_security_group_ingress(
            GroupId=SECURITY_GROUP_ID,
            IpPermissions=[
                {
                    'IpProtocol': 'tcp',
                    'FromPort': 22,
                    'ToPort': 22,
                    'IpRanges': [{'CidrIp': f'{ip}/32'}]
                }
            ]
        )
        print(f"Unblocked IP {ip}: {response}")
    except Exception as e:
        print(f"Error unblocking IP {ip}: {str(e)}")
