# Part 2 - Distributed Database Planning

The bank has three branches: Tunis, Sousse, and Sfax. Each branch has its own local database server, and all servers are connected through the bank's private network.

## 1. Horizontal Fragmentation of the Customers Table

The Customers table is split by branch, so each branch keeps only the rows of its own customers. This is called horizontal fragmentation because we cut the table into pieces by rows, using the branch as the filter.

The full table looks like this:

```
Customers(customer_id, full_name, branch_id, address, phone, email, login_hash, ...)
```

We split it into three pieces:

- Customers_Tunis: all rows where branch_id = 'Tunis', stored in Tunis.
- Customers_Sousse: all rows where branch_id = 'Sousse', stored in Sousse.
- Customers_Sfax: all rows where branch_id = 'Sfax', stored in Sfax.

Each customer belongs to exactly one branch. No row is duplicated. If we put the three pieces back together, we get the original table.

The benefit is that most operations done in a branch (open an account, change an address, list local customers) only need the local fragment. This means faster answers, less traffic on the network, and better data locality.

## 2. Vertical Fragmentation Suggestion

Login information (username, password hash, last login time) is used by the authentication service, not by branch employees. It is also more sensitive than normal customer data. So we move it into a separate table.

We end up with two tables linked by customer_id:

- Customers_Public(customer_id, full_name, branch_id, address, phone, email): used every day by branch staff.
- Customers_Auth(customer_id, login_username, password_hash, last_login_at): used only by the login system.

Reasons for this split:

- Security: credentials live in a separate, better protected table.
- Performance: branch queries do not have to read columns they never use.
- We can still get the original row by joining the two tables on customer_id.

## 3. What Should Be Replicated

| Data                | Replicated to all branches | Reason                                                                                                       |
|---------------------|----------------------------|--------------------------------------------------------------------------------------------------------------|
| Customer info       | Yes                        | A customer from Tunis may visit a branch in Sfax. Branches must be able to look up any customer. Customer info changes rarely, so the cost of copying it is low. |
| Account balances    | Partly                     | The main copy stays at the customer's home branch. Other branches can read it through the network when needed. Keeping a single master copy avoids two branches changing the balance at the same time. |
| Transaction history | No                         | It is very large and grows every day. It is mostly used by the home branch and for end-of-day reports. Copying it everywhere would waste a lot of storage and network bandwidth. |

In short, we copy data that is read often, changed rarely, and needed everywhere (customer info). We keep a single master copy for data that is critical and changes often (balances). We keep large, append-only data at home (transaction history) and only send it to a central place for reports.

## 4. Static or Dynamic Allocation for Transaction History

I would use static allocation.

This means that each transaction is saved at the branch that owns the account, and it stays there forever.

Reasons:

- The access pattern is stable. A transaction is almost always read by the same branch that created it, for statements, audits, and fraud checks. Moving it would not help anyone.
- Audit and legal rules require financial records to be stored in a fixed and traceable place. A fixed location makes backups, retention, and audits much simpler.
- Less complexity. Dynamic allocation would constantly watch access patterns and move data around. This is extra work for no real benefit on append-only history.
- Transaction history is huge. Moving it across the network would be slow and expensive.

Dynamic allocation would make sense for data whose usage changes over time, but a ledger of past transactions does not change behavior, so static allocation is the right choice.
