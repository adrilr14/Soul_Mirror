#version 430
layout(triangles_adjacency) in;
layout(triangle_strip, max_vertices = 15) out;

out vec3 Normal;
out vec3 Position;
out vec2 TexCoords;

// Which output primitives are silhouette edges
flat out float GIsEdge;

in vec3 GPosition[]; // Normal in camera coords.
in vec3 GNormal[]; // Position in camera coords.
in vec2 GTexCoords[]; // COORDENADAS DE TEXTURA

//uniform float EdgeWidth; // Width of sil. edge in clip cds.
//uniform float PctExtend; // Percentage to extend quad
float EdgeWidth = 10.0; // Width of sil. edge in clip cds.
float PctExtend = 10.0; // Percentage to extend quad


bool isFrontFacing(vec3 a, vec3 b, vec3 c)
{
    return ((a.x * b.y - b.x * a.y) + (b.x * c.y - c.x * b.y) + (c.x * a.y - a.x * c.y)) > 0;
}

void emitEdgeQuad(vec3 e0, vec3 e1)
{
    vec2 ext = PctExtend * (e1.xy - e0.xy);
    vec2 v = normalize(e1.xy - e0.xy);
    vec2 n = vec2(-v.y, v.x) * EdgeWidth;

    // Emit the quad
    GIsEdge = 1.0; // This is part of the sil. edge
    gl_Position = vec4( e0.xy - ext, e0.z, 1.0 );
    EmitVertex();

    gl_Position = vec4( e0.xy - n - ext, e0.z, 1.0 );
    EmitVertex();

    gl_Position = vec4( e1.xy + ext, e1.z, 1.0 );
    EmitVertex();

    gl_Position = vec4( e1.xy - n + ext, e1.z, 1.0 );
    EmitVertex();

    EndPrimitive();
}

void main()
{
    vec3 p0 = gl_in[0].gl_Position.xyz / gl_in[0].gl_Position.w;
    vec3 p1 = gl_in[1].gl_Position.xyz / gl_in[1].gl_Position.w;
    vec3 p2 = gl_in[2].gl_Position.xyz / gl_in[2].gl_Position.w;
    vec3 p3 = gl_in[3].gl_Position.xyz / gl_in[3].gl_Position.w;
    vec3 p4 = gl_in[4].gl_Position.xyz / gl_in[4].gl_Position.w;
    vec3 p5 = gl_in[5].gl_Position.xyz / gl_in[5].gl_Position.w;

    if(isFrontFacing(p0, p2, p4)) {
        if(!isFrontFacing(p0,p1,p2)) emitEdgeQuad(p0,p2);
        if(!isFrontFacing(p2,p3,p4)) emitEdgeQuad(p2,p4);
        if(!isFrontFacing(p4,p5,p0)) emitEdgeQuad(p4,p0);
    }

    // Output the original triangle
    GIsEdge = 0.0; // This triangle is not part of an edge.

    Normal = GNormal[0];
    Position = GPosition[0];
    TexCoords = GTexCoords[0];
    gl_Position = gl_in[0].gl_Position;
    EmitVertex();

    Normal = GNormal[2];
    Position = GPosition[2];
    TexCoords = GTexCoords[2];
    gl_Position = gl_in[2].gl_Position;
    EmitVertex();

    Normal = GNormal[4];
    Position = GPosition[4];
    TexCoords = GTexCoords[4];
    gl_Position = gl_in[4].gl_Position;
    EmitVertex();

    EndPrimitive();
}
