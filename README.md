# HN Since Your Last Visit

[HNSince.com](https://hnsince.com) - See all the top HN stories since the time you were last visiting.

- Data from official HN API
- Looks just like you're used to
- All links go straight back to HN
- Minumum time window is 1 hour (otherwise new stories don't have time to gather votes)

## About

Miss a day in HN and you're behind on industry news. What if you want to have a weekly relationship? What if you just want to see whatever you missed since you last visited? This is the tool for you.

## Run a local server

Prequisites

- Erlang/OTP 23
- Elixir 1.11+
- Phoenix
- PostgreSQL (or just `docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:11`)

```
mix deps.get
npm install --prefix assets
mix ecto.setup
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production

It's hosted on DigitalOcean, CD through the `production` branch.

## Contributing

Feel free to make PR's or issues with bugs and feature requests.
