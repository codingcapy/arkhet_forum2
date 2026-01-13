import gleam/result

pub type AsyncData(data, error) {
  NotAsked
  Loading
  Done(Result(data, error))
}

pub fn map(async_data: AsyncData(a, e), with fun: fn(a) -> b) -> AsyncData(b, e) {
  case async_data {
    NotAsked -> NotAsked
    Loading -> Loading
    Done(inner) -> Done(result.map(over: inner, with: fun))
  }
}
