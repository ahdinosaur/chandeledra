use rayon::prelude::*;

use scene;
use color;

static MS_PER_S: f32 = 1.0e9; // microseconds_per_second

#[derive(Debug)]
pub struct Rainbow;
impl scene::Scene for Rainbow {
    fn new () -> Self where Self:Sized {
        return Rainbow {}
    }
    fn render (&self, input: scene::RenderInput) -> scene::RenderOutput {
        let time = input.time;
        let shape = input.shape;

        let dots = &shape.dots;

        let length = dots.len();
        let speed = (0.25_f32) / MS_PER_S;
        let start = time * speed;
        let step = 1_f32 / length as f32;

        debug!("rainbow: {} {} {} {}", time, speed, start, step);

        let colors = (0..length)
            .into_par_iter()
            .map(|index| {
                return color::Color::Hsl(color::Hsl {
                    hue: start + (index as f32 / length as f32),
                    saturation: 1_f32,
                    lightness: 0.5_f32
                })
            })
            .collect();

        return colors;
    }
}
