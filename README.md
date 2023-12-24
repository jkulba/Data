# JSON Data

This repository is used to house JSON data files that can be served using the awesome 'My JSON Server' project.
- My JSON Server does NOT modify the data to the db.json file.
- The service caches the change.

## References
- My JSON Server - https://my-json-server.typicode.com/

## User Actions
### Get All Users
(GET) https://my-json-server.typicode.com/jkulba/Data/users

### Add New User
(POST) https://my-json-server.typicode.com/jkulba/Data/users
```json
{
    "id": 0,
    "name": "Zoey Miller",
    "username": "zoey",
    "email": "zoey@mail.com",
    "address": {
        "street": "932 Johnson",
        "suite": "APT 100",
        "city": "Madison",
        "zipcode": "50123",
        "geo": {
            "lat": "43.0793",
            "lng": "-89.3778"
        }
    },
    "phone": "1-608-555-1212",
    "website": "statefarm.org",
    "company": {
        "name": "Z Insurance",
        "catchPhrase": "Multi-layered client-server neural-net",
        "bs": "harness real-time e-markets"
    }
}
```
### Update User
(PUT) https://my-json-server.typicode.com/jkulba/Data/users/3
```json
{
      "id": 3,
      "name": "Oscar Hendrickx Smith",
      "username": "oscarhkx",
      "email": "janssens.noemie@advalvas.be",
      "address": {
        "street": "4216 S Eldridge St",
        "suite": "APT 203",
        "city": "Morrison",
        "zipcode": "80465",
        "geo": {
          "lat": "39.6364272",
          "lng": "-105.155812"
        }
      },
      "phone": "1-770-736-8031 x56442",
      "website": "hildegard.org",
      "company": {
        "name": "Lacroix EBVBA",
        "catchPhrase": "Multi-layered client-server neural-net",
        "bs": "harness real-time e-markets"
      }
}
```
### 
(DEL) https://my-json-server.typicode.com/jkulba/Data/users/3

