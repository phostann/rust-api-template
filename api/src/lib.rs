use std::env;

use axum::Router;
use service::sea_orm::{Database, DatabaseConnection};

use crate::test::init_test_routes;

mod test;

#[tokio::main]
async fn start() -> anyhow::Result<()> {
    env::set_var("RUST_LOG", "debug");

    tracing_subscriber::fmt::init();
    dotenv::dotenv().ok();

    let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
    let host = env::var("HOST").expect("HOST is not set");
    let port = env::var("PORT").expect("PORT is not set");
    let server_addr = format!("{}:{}", host, port);

    let conn = Database::connect(&db_url)
        .await
        .expect("Could not connect to database");

    let state = AppState { conn };

    let test_routes = init_test_routes();
    let api_routes = Router::new().merge(test_routes);

    let app = Router::new().nest("/v1", api_routes).with_state(state);

    let listener = tokio::net::TcpListener::bind(&server_addr)
        .await
        .expect("Could not bind to address");

    tracing::debug!("Listening on: {}", listener.local_addr().unwrap());

    axum::serve(listener, app).await.expect("Server failed");

    Ok(())
}

pub fn main() {
    let result = start();

    if let Some(err) = result.err() {
        eprintln!("Error: {:?}", err);
    }
}

#[derive(Clone)]
pub struct AppState {
    pub conn: DatabaseConnection,
}
