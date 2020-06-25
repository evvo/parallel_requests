# parallel_requests

Parallel requests is an example of a small application for making parallel requests
for URLs and collecting the information for their statuses.

The application can use the Crystal language (still beta at the time of writing) multithreading features.

## Installation

Install the required dependency shards:
```bash
shards install
```

Run the included migrations:
```bash
./migration.sh up
```

Run the application:
```bash
crystal run src/parallel_requests.cr
```

or you can try the new, multithreading support (still beta in Crystal):

```bash
crystal run -Dpreview_mt src/parallel_requests.cr
```

Production build
```bash
shards build --production
```

## Architecture

The application creates 2 fibers - one for fetching the records from the database in batches and one for receiving these records and processing them.

After the second fiber receives the jobs, it will spawn a new fiber for each job, which will process it.

After certain record is processed, it's result is received from the results_channel and saved to the database.

Since the used database (at the moment) is SQlite, there are some database locks situations that needs to be handled.

## How it works ?

When you run the application, one of the fibers will be running a loop, that will
be looking for records with status = "NEW" and will process them in batches of MAX_BATCH_REQUESTS (10 by default) every second.

## Contributing

1. Fork it (<https://github.com/evvo/parallel_requests/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Evtimiy Mihaylov](https://github.com/evvo) - creator and maintainer
