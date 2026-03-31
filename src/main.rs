use bevy::prelude::*;
use std::f32::consts::PI;
// use bevy_ecs::prelude::*;
use bevy_app::{App, Startup};
use bevy_prng::WyRand;
use bevy_rand::prelude::{EntropyPlugin, GlobalRng};
// use rand_core::Rng;
use rand::RngExt;
// use binary_greedy_meshing as bgm;

const CS: usize = 80;

#[derive(Component)]
pub struct Player {
    move_cooldown: Timer,
}

#[derive(Component, Copy, Clone)]
pub struct Position {
    pub x: usize,
    pub y: usize,
    pub z: usize,
}

#[derive(PartialEq, Copy, Clone)]
enum TileType {
    Wall,
    Floor,
}

#[derive(Component)]
struct Map(Vec<TileType>);

fn linearize<const CS: usize>(x: usize, y: usize, z: usize) -> usize {
    z + (x * CS) + (y * (CS * CS))
}

fn setup_map(mut commands: Commands, mut rng: Single<&mut WyRand, With<GlobalRng>>) {
    let mut map = vec![TileType::Floor; 80 * 80];

    // Make the boundaries walls
    for x in 0..80 {
        map[linearize::<CS>(x, 0, 0)] = TileType::Wall;
        map[linearize::<CS>(x, 0, 79)] = TileType::Wall;
    }
    for z in 0..80 {
        map[linearize::<CS>(0, 0, z)] = TileType::Wall;
        map[linearize::<CS>(79, 0, z)] = TileType::Wall;
    }

    // Now we'll randomly splat a bunch of walls. It won't be pretty, but it's a decent illustration.
    for _i in 0..400 {
        let x = rng.random_range(1..79);
        let z = rng.random_range(1..79);
        let idx = linearize::<CS>(x, 0, z);
        if idx != linearize::<CS>(40, 0, 40) {
            map[idx] = TileType::Wall;
        }
    }

    eprintln!("setup_map...");
    commands.spawn(Map(map));
}

fn spawn_player(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
) {
    commands.spawn((
        Mesh3d(meshes.add(Cuboid::new(1.0, 1.0, 1.0))),
                    MeshMaterial3d(materials.add(Color::srgb_u8(255, 255, 0))),
                    Transform::from_xyz(40.0, 0.5, 40.0),
        Player {move_cooldown: Timer::from_seconds(0.1, TimerMode::Once)},
        Position {x: 40, y: 0, z: 40},
    ));
}


#[allow(unused_mut)]
fn map_pos_enterable(
    delta_x: i32,
    delta_z: i32,
    mut player_position: &Single<&mut Position, With<Player>>,
    map: &Single<&Map>) -> bool
{
    // First check that we aren't trying to move to a negative map position
    if (player_position.x as i32 + delta_x) < 0 || (player_position.z as i32 + delta_z) < 0 {
        return false
    }
    // We should not overflow so using strict_add_signed is fine
    let destination_idx = linearize::<CS>(player_position.x.strict_add_signed(delta_x as isize), 0, player_position.z.strict_add_signed(delta_z as isize));
    if map.0[destination_idx] != TileType::Wall {
        return true;
    } else {
        return false;
    }
}


fn player_input(
    keyboard_input: Res<ButtonInput<KeyCode>>,
    mut player: Single<&mut Player>,
    mut player_position: Single<&mut Position, With<Player>>,
    mut player_transform: Single<&mut Transform, With<Player>>,
    map: Single<&Map>,
    time: Res<Time>,
) {
    if player.move_cooldown.tick(time.delta()).is_finished() {
        let mut moved = false;
        if keyboard_input.pressed(KeyCode::ArrowLeft) {
            if map_pos_enterable(-1, 0, &player_position, &map) {
                player_position.x = player_position.x - 1;
                player_transform.translation.x = player_transform.translation.x - 1.0;
                moved = true;
            }
        }
        if keyboard_input.pressed(KeyCode::ArrowRight) {
            if map_pos_enterable(1, 0, &player_position, &map) {
                player_position.x = player_position.x + 1;
                player_transform.translation.x = player_transform.translation.x + 1.0;
                moved = true;
            }
        }
        if keyboard_input.pressed(KeyCode::ArrowUp) {
            if map_pos_enterable(0, -1, &player_position, &map) {
                player_position.z = player_position.z - 1;
                player_transform.translation.z = player_transform.translation.z - 1.0;
                moved = true;
            }
        }
        if keyboard_input.pressed(KeyCode::ArrowDown) {
            if map_pos_enterable(0, 1, &player_position, &map) {
                player_position.z = player_position.z + 1;
                player_transform.translation.z = player_transform.translation.z + 1.0;
                moved = true;
            }
        }
        if moved {
            player.move_cooldown.reset();
        }
    }
}


fn draw_map(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    map: Single<&Map>,
) {
    let mut z = 0;
    let mut x = 0;
    for tile in map.0.iter() {
        // Render a tile depending upon the tile type
        match tile {
            TileType::Floor => {
                commands.spawn((
                    Mesh3d(meshes.add(Rectangle::new(1.0, 1.0))),
                    MeshMaterial3d(materials.add(Color::srgb_u8(128, 192, 128))),
                    Transform::from_xyz(x as f32, 0.0, z as f32)
                        .with_rotation(Quat::from_rotation_x(-PI / 2.0)),
                ));
            }
            TileType::Wall => {
                commands.spawn((
                    Mesh3d(meshes.add(Cuboid::new(1.0, 1.0, 1.0))),
                    MeshMaterial3d(materials.add(Color::srgb_u8(0, 0, 0))),
                    Transform::from_xyz(x as f32, 0.5, z as f32),
                ));
            }
        }

        // Move the coordinates
        z += 1;
        if z > 79 {
            z = 0;
            x += 1;
        }
    }

    // Add light
    commands.spawn((
        DirectionalLight {
            illuminance: 1000.0,
            shadows_enabled: true,
            ..default()
        },
        Transform::from_xyz(40.0, 10.0, 40.0).looking_to(Dir3::NEG_Y, Vec3::Y),
    ));
    // Add camera
    commands.spawn((
        Camera3d::default(),
        Transform::from_xyz(100.0, 70.0, 100.0).looking_at(Vec3::new(52.5, 0.0, 52.5), Vec3::Y),
    ));
}

fn main() {
    App::new()
        .add_plugins((DefaultPlugins, EntropyPlugin::<WyRand>::default()))
        .add_systems(Startup, (setup_map, spawn_player))
        .add_systems(PostStartup, draw_map)
        .add_systems(FixedUpdate, player_input)
        .run();
}
