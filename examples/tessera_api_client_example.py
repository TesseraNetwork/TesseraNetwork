import requests

# Assuming your proxy is running on http://localhost:3000
# and the proxy route is /api/tessera/
PROXY_BASE_URL = 'http://localhost:3000/api/tessera'

def make_api_request(api_path_suffix, method='GET', data=None):
    # Construct the URL to hit the proxy, then the proxy will forward to the actual API
    url = f'{PROXY_BASE_URL}/{api_path_suffix}'
    headers = {
        # The API key is now handled by the proxy server, so it's not included here
        'Content-Type': 'application/json'
    }
    print(f"Making {method} request to: {url}") # For debugging

    if method.upper() == 'GET':
        response = requests.request(method, url, headers=headers, params=data)
    else:
        response = requests.request(method, url, headers=headers, json=data)
    response.raise_for_status()
    return response.json()

# Example: Reading Entities
# The 'apps/...' part is the 'api_path_suffix' for the proxy
entities_path = 'apps/6986868d8f619eaab253487e/entities/Endpoint'
try:
    entities = make_api_request(entities_path)
    print("\n--- Entities ---")
    print(entities)
except requests.exceptions.RequestException as e:
    print(f"Error making API request: {e}")
    if e.response is not None:
        print(f"Response content: {e.response.text}")


# Example: Updating an Entity
# Need an actual entity_id to update. This example assumes you have one.
# For demonstration, I'll use a placeholder and show the modified function structure.
# You would get a real entity_id from the 'entities' list if it were populated.

def update_entity(entity_id, update_data):
    url = f'{PROXY_BASE_URL}/apps/6986868d8f619eaab253487e/entities/Endpoint/{entity_id}'
    headers = {
        # The API key is now handled by the proxy server
        'Content-Type': 'application/json'
    }
    print(f"Making PUT request to: {url} with data: {update_data}") # For debugging

    response = requests.put(url, headers=headers, json=update_data)
    response.raise_for_status()
    return response.json()

# Placeholder for actual update data and entity_id
# If you run the make_api_request successfully, you could use an ID from `entities`
# For now, this is just to show the structure.
# example_entity_id = "some_actual_entity_id_from_your_api"
# example_update_data = {"description": "Updated via proxy"}

# try:
#     # updated_entity = update_entity(example_entity_id, example_update_data)
#     # print("\n--- Updated Entity ---")
#     # print(updated_entity)
# except requests.exceptions.RequestException as e:
#     print(f"Error updating entity: {e}")
#     if e.response is not None:
#         print(f"Response content: {e.response.text}")
