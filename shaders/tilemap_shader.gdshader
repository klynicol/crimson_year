shader_type canvas_item;

uniform float perspective_strength = 9e-05;
uniform float center_x = 0.0;  // X center point for perspective (world coords)
uniform float horizon_y = -300.0;  // Y position of the horizon/vanishing point (top of your tilemap)

void vertex() {
    // Get world position using the model matrix
    vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0);
    
    // Calculate distance from horizon (always positive, increases downward)
    float dist_from_horizon = world_pos.y - horizon_y;
    
    // Calculate perspective scale based on distance from horizon
    float scale = 1.0 + (dist_from_horizon * perspective_strength);
    
    // Scale X position relative to center point
    float offset_from_center = world_pos.x - center_x;
    float new_x = center_x + (offset_from_center * scale);
    
    // Apply the difference back to VERTEX
    VERTEX.x += (new_x - world_pos.x);
}