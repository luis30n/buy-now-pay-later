# Introduction

This repository is the deliverable of the SeQura Senior Backend Developer coding challenge.
It is a simplified version of SeQura's daily problems.

For more context, please visit: https://sequra.github.io/backend-challenge/

# How to set up and run

The project is configured to use docker and docker compose. 
It has been tested with docker compose version v2.20.2-desktop.1 and docker version 24.0.6.

To run the project, you can simply use the following command:
```bash
docker compose up
```
This will run rails, sidekiq, redis and postgresql as docker containers. 
The first run will take some minutes because the following steps are performed:
- Base container images are downloaded to your system and the images defined in `Dockerfile` and `Dockerfile.postgres` are built.
- The rails migrations are run.
- Rake tasks to import merchants and orders from CSV files are performed. 
- A rake task to generate disbursements from the imported past orders is performed.

NOTE: A volume is used to save the state of the postgresql database service so that, once set up, these steps are not necessary after a restart. If you want, for some reason, you would like to trigger the set up from the begginining, you can use the following commands:
```bash
  docker compose down # stop containers
  docker volume rm sequra_postgres_data # delete the DB volume
  docker compose up --build # start the containers, forcing a re-build
```
# How to use this application

Once the application is up and running and the data has already been imported and processed (you can check the logs to verify this), the app can be used to get stats about the disbursements calculated for 2022 and 2023. This information is already included in `data/stats.csv`. To test the behavior, the CSV file can be deleted and a rake task can be invoked to generate the stats:
```bash
  rm data/stats.csv
  docker exec rails bundle exec rake disbursements:generate_stats
```
Once the task has finished, you can check the stats at `data/stats.csv`.
It should look like this:
| Year   | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee) |
| ------ | ----------------------- | ------------------------------ | -------------------- | ---------------------------------------------------------- | -------------------------------------------------------- |
| 2022 | 3502                    | 16121669.1 €                  | 149977.24 €         | 8                                                           | 157.31 €                                                |
| 2023 | 1354                    | 17893192.67 €                 | 164532.83 €         | 7                                                           | 114.26 €                                                |

NOTE: The minimum monthly fee calculations have not been substracted from disbursements. A TODO comment has been added to indicate where this fee should be taken into account.


# Design Decisions

An explanation of technical choices, tradeoffs and assumptions taken during the development of this challenge can be found [here](./docs/design-decisions.md)