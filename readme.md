# Database developer 

Results of the database developer's test.

## Contents

- [Importing, validating and sanitising data](./docs/DataValidationAndCleanup.md)
- [Current purchase price](./docs/T-01.md)
- [Categorised purchases](./docs/T-02.md)
- [The difference in the purchase price](./docs/T-03.md)
- [Data structure](./docs/T-04.md)
- [Customers' duplicates](./docs/T-05.md)
- [Split sales records](./docs/T-06.md)
- [Load JSON data](./docs/T-07.md)

## Restoring data

```shell
pg_restore --dbname=testdb --format=c --username=postgres --host=localhost --port=5432 ~/Downloads/db-backup.dump
```

Modify command if needed to suit your needs.