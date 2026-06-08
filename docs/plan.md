# snegs

Technical: A high-level content DSL for humans and agents.

gs Language:

domain (gs)
```
name () str {
  desc = "A general name type";
  min = 2;
  max = 64;
}

qty (limit: int) int {
  desc = "A quantity data type";
  min = 1;
  max = limit;
}

product {
  limit: int,
  stock: int,
  desc: str,
  name: name,
  price: dbl,
  quantity: qty,
}
```

data (sql)
```
table: inventory
---
id: 1
stock: 50
name: Soap
desc: Green soap for dogs
price: 10.5
```

product (html)
```
<article>
  <h4>{name}</h4>
  <p>{desc}</p>
  <p>
    <span>
      {currency(price)}
    </span>
    <span>
      {input(quantity)}/{limit} - {stock} available
    </span>
  </p>
</article>
```

## General Pages

- Home
- Login
- About
- Pricing

## Admin Pages

- Dashboard
- Brand
- System
  - Blocks
  - Actions
  - Pages
  - Products
  - Email
- Orders
- Reports
- Settings
