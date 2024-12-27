use actix_files::Files;
use actix_web::{web, App, HttpServer, Responder};
use log::{info, error};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct GreetingRequest {
    name: String,
}

#[derive(Serialize)]
struct GreetingResponse {
    message: String,
}

async fn greet(req: web::Json<GreetingRequest>) -> impl Responder {
    info!("Received request to /api/greet with name: {}", req.name);
    let message = format!("Hello, {}!", req.name);
    web::Json(GreetingResponse { message })
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Initialize the logger
    env_logger::init();

    let address = "127.0.0.1";
    let port = 8080;

    info!("Starting server at http://{}:{}", address, port);

    HttpServer::new(|| {
        App::new()
            .route("/api/greet", web::post().to(greet)) // API route
            .service(Files::new("/", "./public").index_file("index.html")) // Serve static files
    })
    .bind((address, port))?
    .run()
    .await
}
