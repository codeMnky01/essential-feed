# essential-feed
Essential Feed case study

## Story: Customer requests to see their image feed

### Narative #1

```
As online customer 
I want app to automaticaly load my latest image feed
So i can always enjoy newest images of friends
```

#### Scenarios (Acceptance criteria)

```
 Given the customer have connectivity
  When the customer reqeusts to see their feed
  Then the app should display latest feed from remote
   And replace cache with new feed
```

### Narative #2

```
As offline customer 
I want app to automaticaly load cached feed
So i can always enjoy cached images while offline
```

#### Scenarios (Acceptance criteria)

```
 Given the customer doesn't have connectivity
   And there is a cached version of the feed 
   And the cache is less then 7 days old
  When the customer request to show the feed
  Then the app displays cache image feed

 Given the customer doesn't have connectivity
   And there is a cached version of the feed 
   And the cache is 7 days old or more
  When the customer request to show the feed
  Then the app displays error message
  
 Given the customer doesn't have connectivity
   And the cache is empty
  When the customer request to show the feed
  Then the app displays error message
```

## Use Cases
### Load Feed from Remote - Use Case
Data: 
- URL
##### Primary course (happy path):
1. Execute "Load Image Feed" command with above data
2. System downloads data from URL
3. System validates downloaded data
4. System creates image feed from valid data
5. System delivers image feed

##### Invalid data - error course (sad path):
1. System delivers invalid data error

##### No connection - error course (sad path):
1. System delivers no connection error
---

### Load Image data from Remote - Use Case
Data: 
- URL
##### Primary course (happy path):
1. Execute "Load Image Data" command with above data
2. System downloads data from URL
3. System validates downloaded data
4. System delivers image feed

##### Cancel course:
1. System dosn't delivers image nor error

##### Invalid data - error course (sad path):
1. System delivers invalid data error

##### No connection - error course (sad path):
1. System delivers no connection error
---

### Load Feed from Cache - Use Case
Data: 
- URL
##### Primary course (happy path):
1. Execute "Load Image Feed" command with above data
2. System retrieves image feed data from cache
3. System validates cache is less then 7 days old
4. System creates image feed from valid data
5. System delivers image feed

##### Retrieval error course (sad path):
1. System delivers retrieval error

##### Expired cache course (sad path):
1. System delivers no feed images

##### Empty cache course (sad path):
1. System delivers no feed images
---

### Load Image data from Cache - Use Case
Data: 
- URL
##### Primary course (happy path):
1. Execute "Load Image Data" command with above data
2. System retrieves image data from cache
3. System validates cache is less then 7 days old
4. System delivers image

##### Cancel course:
1. System doesn't deliver image nor error

##### Retrieval error course (sad path):
1. System delivers retrieval error

##### Empty cache course (sad path):
1. System delivers no feed images
---

### Validate Feed Cache - Use Case
##### Primary course (happy path):
Data:
- Cache
1. Execute "Validate Cache" command with above data
2. System retrieves cached data
3. System validates cache is less then 7 days old

##### Retrieval error course (sad path):
1. System deletes cache

##### Empty cache course (sad path):
1. System deletes cache 
---

### Cache Feed - Use Case
##### Primary course (happy path):
Data:
- Image Feed
1. Execute "Save Image Feed" command with above data
2. System deletes old cache
3. System encodes new image feed
4. System timestamps encoded image feed
5. System saves new cached data
6. System delivers susccess message

##### Deleting error course (sad path):
1. System delivers error

##### Saving error course (sad path):
1. System deletes cache 
---

### Save Image data to Cache - Use Case
##### Primary course (happy path):
Data:
- Image Data
1. Execute "Save Image Data" command with above data
2. System saves new cached data
3. System delivers susccess message

##### Saving error course (sad path):
1. System deletes cache 
---

## Flowchart
![Image](flowchart.png)

## Model Specs

### Feed Image
| Property | Type |
| --- | --- |
| `id` | `UUID` |
| `description` | `String` (optional) |
| `location` | `String` (optional) |
| `url` | `URL` |

### Payload Contract
```
GET /feed

200 RESPONSE

{
	"items": [
		{
			"id": "a UUID",
			"description": "a description",
			"location": "a location",
			"image": "https://a-image.url",
		},
		{
			"id": "another UUID",
			"description": "another description",
			"image": "https://another-image.url"
		},
		{
			"id": "even another UUID",
			"location": "even another location",
			"image": "https://even-another-image.url"
		},
		{
			"id": "yet another UUID",
			"image": "https://yet-another-image.url"
		}
		...
	]
}
```


