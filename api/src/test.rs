use axum::Router;
use axum::routing::get;
use crate::AppState;

pub fn init_test_routes() -> Router<AppState> {
    Router::new()
        .route("/ping", get(|| async { "pong" }))
}
