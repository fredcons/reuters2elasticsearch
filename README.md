A small utility script to transform the original reuters news dataset into a bulk elasticsearch import

It relies mostly on [this original script](http://earlh.com/blog/2011/06/18/prepping-the-reuters-21578-classification-sample-dataset/), with title extraction and bulk file generation added.

## Prequisites

The hpricot gem should be installed

## Usage

- Put the reuters dataset .sgm files in the same folder than this script
- Run 

```
ruby reuters2elasticsearch.rb
```

The folder now contains a `reuters.bulk.json` file that is ready to be bulk-imported in ElasticSearch, with for example : 

```
# create index (modify schema to suit your needs)
curl -XPUT http://localhost:9200/reuters -d '{
  "settings" : {
    "number_of_shards"   : 5,
    "number_of_replicas" : 0,
    "analysis" : {
      "tokenizer" : {
      },
      "analyzer" : {
      }
    }
  },
  "mappings" : {
    "articles" : {
      "dynamic" : false,
      "properties" : {          
        "title" : {
          "type" : "string"
        },          
        "body" : {
          "type" : "string"
        }
      }
    }
  }
}'


# import data
curl -XPUT http://localhost:9200/reuters/articles/_bulk --data-binary @reuters.bulk.json

# count articles
curl -XGET http://localhost:9200/reuters/articles/_count
```

