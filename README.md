# HN Since Your Last Visit

[HNSince.com](https://hnsince.com) - See all the top HN stories since the time you were last visiting.

- Data from official HN API
- Looks just like you're used to
- All links go straight back to HN
- Minumum time window is 1 hour (otherwise new stories don't have time to gather votes)

## About

I check HN sometimes hourly, sometimes monthly, (rarely, but) sometimes quarterly. I don't know how long I've been away and the FOMO on good stories was driving me nuts. There is the kind of secret [/best](https://news.ycombinator.com/best) section on HN, but that only covers a week (I think). So this idea came to me and took **only** a year to finally sit down and write it.

Temporary plug: Me and my team at [randomforest.ee](https://randomforest.ee/) are available for hire.

## Run a local server

Prequisites

- Erlang/OTP 23
- Elixir 1.11+
- Phoenix
- PostgreSQL (or just `docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:11`)

```
mix deps.get
mix ecto.setup
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Contributing

Feel free to make PR's or issues with bugs and feature requests.
