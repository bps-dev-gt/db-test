# Data Validation and Cleanup

Reliability validation is performed on incoming data. Some data is related to others, as shown by the data structure and the instructions provided. There are a total of six subtests that check for the presence of foreign data.

Test are available in script [DataValidationTest](../scripts/DataValidationTests.sql).

# Result of validation

| tableName             | validationTest                            | passedValidation | invalidRecords |
| --------------------- | ----------------------------------------- | ---------------- | -------------- |
| `tst_myynti`          | Doesn't contain invalid customers         | ✓                | 0              |
| `tst_myynti`          | Doesn't contain invalid products          |                  | 2104           |
| `tst_ostohinta`       | Doesn't contain invalid supplier products |                  | 643586         |
| `tst_saldo`           | Doesn't contain invalid products          |                  | 3496           |
| `tst_toimittajatuote` | Doesn't contain invalid products          |                  | 104773         |
| `tst_tuote`           | Doesn't contain invalid categories        | ✓                | 0              |

Only two tables containing foreign data have successfully passed validation, as seen in the table above.

Why the data is inconsistent is not something we will speculate about. 

## Cleanup

Given the lack of clear instructions and explanation of the missing foreign data, we will be sanitising any incoming data. 

Tables that necessitate disinfection:

- `tst_myynti`
- `tst_ostohinta`
- `tst_saldo`
- `tst_toimittajatuote`

Sanitized data is stored into schema `sanitized`. The original table names with the prefix `san_` are being used..

Data sanitisation commands are available in script [DataCleanUp](../scripts/DataCleanUp.sql).

## Optimal database structure

Implementing an optimal database structure is our next step. 

In given data Finnish names are used for database and column names. Using localised names for tables and columns is not that are optimal. Data will likely be shared or utilised in other application layers, therefore naming conventions should be adequate to accommodate new integrations or layers. To further guarantee future data synchronisation without collisions, we will also be replacing primary numeric keys with UUIDs.

We will utilise intermediate tier data that is imported into the final schema to ensure data traceability from entering sources to the end solution. To simplify procedure we add additional columns into the `san_` tables.

Columns and related data creation commands are in script [IntermediateDataStructure](../scripts/IntermediateDataStructure.sql).

The next step is to import cleaned data and construct a new data structure. Related commands are in script [NewStructureWithImport](../scripts/NewStructureWithImport.sql).

We check the final tables for a valid number of records once we have all of the data.

In the first round of validation, the value in the `rowsCountDiff` column for each table should match the value in the `invalidRecords` field.

| tableName                          | sourceableName        | rowsCount | incomingRowsCount | rowsCountDiff |
| ---------------------------------- | --------------------- | --------- | ----------------- | ------------- |
| `Customers`                        | `tst_asiakas`         | 48        | 48                | 0             |
| `ProductCategories`                | `tst_tuoteryhma`      | 728       | 728               | 0             |
| `Products`                         | `tst_tuote`           | 127011    | 127011            | 0             |
| `ProductSales`                     | `tst_myynti`          | 47881     | 49985             | 2104          |
| `PurchasePricesOfSupplierProducts` | `tst_ostohinta`       | 595816    | 1239402           | 643586        |
| `StockOfProducts`                  | `tst_saldo`           | 29144     | 32640             | 3496          |
| `SupplierProducts`                 | `tst_toimittajatuote` | 126928    | 231701            | 104773        |

The data was imported into the new data structure without problems.

