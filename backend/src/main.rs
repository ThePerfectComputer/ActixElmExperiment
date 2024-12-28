use actix_files::Files;
use actix_web::{web, App, HttpServer, Responder, HttpRequest, HttpResponse, Error};
use actix_web_actors::ws;
use log::{info};
use serde::{Deserialize, Serialize};
use std::time::Duration;
use actix::prelude::*;

/// Greeting API structures
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

/// WebSocket actor
struct MyWebSocket;

impl Actor for MyWebSocket {
    type Context = ws::WebsocketContext<Self>;

    fn started(&mut self, ctx: &mut Self::Context) {
        info!("WebSocket actor started");
        // Send messages every second
        ctx.run_interval(Duration::from_secs(1), |_, ctx| {
            let message = format!("{{\"time\" : \"{:?}\" }}", chrono::Local::now());
            ctx.text(message);
        });
        info!("Leaving started");
    }
}

impl StreamHandler<Result<ws::Message, ws::ProtocolError>> for MyWebSocket {
    fn handle(&mut self, msg: Result<ws::Message, ws::ProtocolError>, ctx: &mut ws::WebsocketContext<Self>) {
        if let Ok(ws::Message::Ping(msg)) = msg {
            ctx.pong(&msg);
        }
    }
}

async fn websocket_handler(req: HttpRequest, stream: web::Payload) -> Result<HttpResponse, Error> {
    ws::start(MyWebSocket {}, &req, stream)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();

    let address = "127.0.0.1";
    let port = 8080;

    info!("Starting server at http://{}:{}", address, port);

    HttpServer::new(|| {
        App::new()
            .route("/api/greet", web::post().to(greet)) // Greeting API
            .route("/ws/", web::get().to(websocket_handler)) // WebSocket endpoint
            .service(Files::new("/", "./public").index_file("index.html")) // Serve frontend
    })
    .bind((address, port))?
    .run()
    .await
}
