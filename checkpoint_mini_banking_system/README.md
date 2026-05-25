# Mini Banking System - Transaction Flow and Distribution Planning

This checkpoint has two parts:

1. Concurrency control in a small banking system.
2. Distributed database design across three bank branches.

## Project Structure

```
checkpoint_mini_banking_system/
├── 01_transaction_management.md         (Part 1: locks and safe schedules)
├── 02_distributed_database_planning.md  (Part 2: fragmentation and replication)
└── README.md
```

## Part 1 - Transaction Management

The scenario is two users transferring money from the same account at the same time. The file explains:

- Which concurrency problem can happen (Lost Update, with a note about Dirty Read).
- A locking mechanism based on row-level exclusive locks held until the transaction commits.
- Why pessimistic locking is the better choice for a banking workload.
- Two side-by-side schedules of operations: one unsafe (loses an update) and one safe (gives the correct result).

## Part 2 - Distributed Database Planning

The bank has three branches: Tunis, Sousse, and Sfax. The file explains:

- How to split the Customers table by branch (horizontal fragmentation).
- How to move login information into a separate table (vertical fragmentation).
- Which data should be replicated across all branches and which should not.
- Why transaction history is best stored using static allocation.

Open the two Markdown files for the detailed answers.
