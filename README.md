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

## UML

## Contract


