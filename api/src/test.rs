use crate::AppState;
use axum::routing::get;
use axum::Router;

pub fn init_test_routes() -> Router<AppState> {
    Router::new().nest(
        "/test",
        Router::new().route("/ping", get(|| async { "pong" })),
    )
}
