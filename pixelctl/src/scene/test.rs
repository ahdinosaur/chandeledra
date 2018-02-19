use scene;
use color;

#[derive(Debug)]
pub struct Test;
impl scene::Scene for Test {
    fn new () -> Self where Self:Sized {
        return Test {}
    }
    fn scene<'a> (&self, input: scene::SceneInput<'a>) -> scene::SceneOutput<'a> {
        let shape = input.shape;

        let dots = &shape.dots;
        let length = dots.len();
        
        let colors = (0..length)
            .map(|_index| {
                return color::Color::Rgb(color::Rgb {
                    red: 1_f32,
                    green: 1_f32,
                    blue: 1_f32
                });
            });

        return Box::new(colors);
    }
}
