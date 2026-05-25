# Part 1 - Transaction Management

## Scenario

In a small banking system, users can transfer money between accounts and check their balances.

Two users start transfers at the same time, and both transfers use the same account (account A).

- Transaction T1: transfer 100 from account A to account B.
- Transaction T2: transfer 50 from account A to account C.

Starting balance of A is 500. The correct final balance should be 500 - 100 - 50 = 350.

## 1. Concurrency Issue

The problem that can happen here is called a Lost Update.

If both transactions run at the same time with no control, they both read the same starting balance (500), each one calculates a new value on its own, and the second update overwrites the first. One of the two withdrawals just disappears.

A second possible problem is a Dirty Read: T2 might read a value that T1 has changed but not yet saved. If T1 is later cancelled, T2 will have used a value that never really existed.

## 2. Proposed Locking Mechanism

I would use an exclusive lock (also called a write lock) on every account row that takes part in a transfer. The lock is held until the transaction finishes.

- A shared lock (read lock) is enough for "view balance", because reading does not change the data and many users can read at the same time.
- A transfer changes the balance, so it needs an exclusive lock. While one transaction holds it, no other transaction can read or write that row.

To avoid two transactions blocking each other forever (deadlock), the system should always lock the rows in the same order, for example by account ID from smallest to largest.

Example in SQL:

```sql
BEGIN;

SELECT balance FROM Accounts
 WHERE account_id IN (:from_id, :to_id)
 ORDER BY account_id
 FOR UPDATE;

UPDATE Accounts SET balance = balance - :amount WHERE account_id = :from_id;
UPDATE Accounts SET balance = balance + :amount WHERE account_id = :to_id;

COMMIT;
```

## 3. Pessimistic or Optimistic Locking

I would use pessimistic locking.

Reasons:

- In a bank, the same accounts (salary accounts, bill payment accounts) are used very often, so conflicts are common. Optimistic locking would cause many transactions to fail and need to be retried.
- Money must always be correct. Pessimistic locking blocks other transactions before they can do any harm, so a lost update is not possible.
- A transfer is short and touches only a few rows, so holding the lock for a short time is not expensive.

Optimistic locking is better when conflicts are rare and most operations are reads, which is not the case here.

## 4. Order of Operations

Starting balances: A = 500, B = 200, C = 100.

### Unsafe schedule (no locking) - Lost Update

| Step | T1 (A to B, 100)            | T2 (A to C, 50)             | Balance of A |
|------|-----------------------------|-----------------------------|--------------|
| 1    | read A = 500                |                             | 500          |
| 2    |                             | read A = 500                | 500          |
| 3    | write A = 500 - 100 = 400   |                             | 400          |
| 4    |                             | write A = 500 - 50 = 450    | 450          |
| 5    | commit                      |                             | 450          |
| 6    |                             | commit                      | 450          |

Final balance of A is 450, but the correct value is 350. T1's withdrawal of 100 is lost. This schedule is not safe.

### Safe schedule (with exclusive lock)

| Step | T1 (A to B, 100)                       | T2 (A to C, 50)                       | Balance of A |
|------|----------------------------------------|---------------------------------------|--------------|
| 1    | begin                                  |                                       | 500          |
| 2    | get exclusive lock on A                |                                       | 500          |
| 3    | read A = 500                           | begin                                 | 500          |
| 4    |                                        | ask for lock on A - has to wait       | 500          |
| 5    | write A = 400, update B                | still waiting                         | 400          |
| 6    | commit (lock on A is released)         |                                       | 400          |
| 7    |                                        | gets the lock, reads A = 400          | 400          |
| 8    |                                        | writes A = 400 - 50 = 350, updates C  | 350          |
| 9    |                                        | commit                                | 350          |

Final balance of A is 350. The result is the same as running T1 first and then T2 one after the other. This schedule is safe.
