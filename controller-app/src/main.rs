extern crate clap_verbosity_flag;
extern crate ezing;
#[cfg(feature = "gl")] extern crate glfw;
#[cfg(feature = "gl")] extern crate kiss3d;
#[cfg(feature = "hal")] extern crate linux_embedded_hal as hal;
#[macro_use] extern crate log;
extern crate modulo;
extern crate nalgebra as na;
extern crate noise;
#[macro_use] extern crate structopt;
extern crate rand;

use std::env;
use structopt::StructOpt;
use clap_verbosity_flag::Verbosity;

mod color;
mod control;
mod display;
mod render;
mod scene;
mod shape;
use shape::AbstractShapeCreator;
mod util;

#[derive(Debug, StructOpt)]
struct CliOptions {
    #[structopt(flatten)]
    verbose: Verbosity,
}

fn main() {
    let cli_options = CliOptions::from_args();

    cli_options.verbose.setup_env_logger("controller-app").unwrap();

    let edge_length = env::var("EDGE_LENGTH").unwrap().parse::<f32>().unwrap();
    let pixel_density = env::var("PIXEL_DENSITY").unwrap().parse::<f32>().unwrap();
    let num_arms = env::var("NUM_ARMS").unwrap().parse::<usize>().unwrap();
    let fps = env::var("FPS").unwrap().parse::<u32>().unwrap();

    let abstract_shape = shape::Tetrahedron::new(edge_length);
    let shape = shape::Shape::new(shape::ShapeOptions {
        abstract_shape,
        pixel_density,
        num_arms
    });

    let (control_tx, control_rx) = control::create_control_channel();

    control::connect_clock(fps, control_tx.clone());

    let display_tx = display::create_display_tx(control_tx.clone());
    let render_tx = render::create_render_tx(display_tx);

    let render_shape = render::RenderMessage::Shape(shape);
    render_tx.send(render_shape).unwrap();
    
    for control_message in control_rx {
        let mut render_message;
        match control_message {
            control::Control::Time(value) => {
                render_message = render::RenderMessage::Time(value);
            },
            control::Control::ChangeMode(value) => {
                render_message = render::RenderMessage::ChangeMode(value);
            }
        }
        render_tx.send(render_message).unwrap();
    }
}

/*
struct LedStrip {
    pub controller: LedController,
    pub leds: Vec<RGB>,
    pub brightness: f32,
    pub temperature: ColorTemperature,
    pub correction: ColorCorrection,
    pub dither: DitherMode,
    pub maxPowerInMilliWatts: i32
}
*/
