#version 430 core

// SALIDA PARA COMUNICAR CON EL RESTO DEL PIPELINE
layout (location = 0) out vec4 FragColor; // COLOR FINAL DEL FRAGMENTO

// ENTRADA, PROVENIENTE DEL GEOMETRY SHADER
in vec3 Position;  // VERTICES EN COORDENADAS DE VISTA
in vec3 Normal;    // NORMALES EN COORDENADAS DE VISTA
in vec2 TexCoords; // COORDENADAS DE TEXTURA

//flat in float GIsEdge; // Whether or not we're drawing an edge

// ESTRUCTURA PARA GUARDAR EL MATERIAL, EN NUESTRO CASO USAMOS TEXTURAS
struct TMaterial {
  sampler2D Diffuse;
  sampler2D Height;
  sampler2D Specular; // metalness
  sampler2D Normal;
  sampler2D Roughness;
  float     Shininess;
};

// ESTRUCTURA PARA GUARDAR LAS LUCES PUNTUALES (POSICION E INTENSIDAD DE LA LUZ)
struct TLuzPuntual {
  vec3 Position;

  vec3 Intensity;
};

// ESTRUCTURA PARA GUARDAR LAS LUCES DIRECCIONALES
struct TLuzDireccional {
  //vec3 Position;
  vec3 Direction;

  vec3 Intensity;

  float Constant;
  float Linear;
  float Quadratic;
};

// ESTRUCTURA PARA GUARDAR LAS LUCES FOCALES
struct TLuzFocal {
  vec3 Position;
  vec3 Direction;

  vec3 Intensity;

  float Apertura;
  float Angular;

  float Constant;
  float Linear;
  float Quadratic;
};

// HAY O NO HAY LUCES ACTIVAS EN LA ESCENA 
//uniform bool lucesActivas;

// POSICION DEL OBSERVADOR
uniform vec3 ViewPos; // POSICION DE LA CAMARA

// ESTADO DE OPENGL: MATERIAL Y LUCES (DEL TIPO DE LAS ESTRUCTURAS ANTERIORES)
uniform TMaterial Material;

uniform int numLucesPuntuales;
#define NUM_LUCES_PUNTUALES 10
uniform TLuzPuntual LucesPuntuales[NUM_LUCES_PUNTUALES];

uniform int numLucesDireccionales;
#define NUM_LUCES_DIRECCIONALES 10
uniform TLuzDireccional LucesDireccionales[NUM_LUCES_DIRECCIONALES];

// COLOR DE LA LINEA
//uniform vec4 LineColor; // The sil. edge color
//const vec4 LineColor = vec4(0.0, 0.0, 0.0, 0.0); // The sil. edge color

uniform int numLucesFocales;
#define NUM_LUCES_FOCALES 10
uniform TLuzFocal LucesFocales[NUM_LUCES_FOCALES];

// VARIABLES PARA EL SHADER CARTOON
//uniform int cartoonParts = 8;
const int levels = 3;
const float scaleFactor = 1.0 / levels;

// FUNCION QUE CALCULA EL MODELO DE REFLEXION DE PHONG PARA LUCES PUNTUALES
vec3 PhongLuzPuntual (TLuzPuntual light, vec3 n, vec3 v)
{
  // CALCULAR LOS DIFERENTES VECTORES
  vec3 s = normalize(light.Position - Position);
  vec3 r = reflect(-s, n);

  // COSENO
  float cosine = max(0.0, dot(s, n));

  // COMPONENTE AMBIENTAL
  vec3 Ambient = light.Intensity * vec3(texture(Material.Diffuse, TexCoords));
  //vec3 Ambient = light.Intensity * texture(Material.Diffuse, TexCoords).rgb;

  // COMPONENTE DIFUSA
  //vec3 Diffuse = light.Intensity * max(dot(s, n), 0.0) * vec3(texture(Material.Diffuse, TexCoords)) * ceil(cosine * levels) * scaleFactor;
  vec3 Diffuse = light.Intensity * max(dot(s, n), 0.0) * vec3(texture(Material.Diffuse, TexCoords)) * floor(cosine * levels) * scaleFactor;
  //vec3 Diffuse = light.Intensity * max(dot(s, n), 0.0) * vec3(texture(Material.Diffuse, TexCoords));
  //vec3 Diffuse = light.Intensity * max(dot(s, n), 0.0) * texture(Material.Diffuse, TexCoords).rgb;

  // COMPONENTE ESPECULAR
  vec3 Specular = light.Intensity * pow(max(dot(r, v), 0.0), Material.Shininess) * vec3(texture(Material.Specular, TexCoords));
  //vec3 Specular = light.Intensity * pow(max(dot(r, v), 0.0), Material.Shininess) * texture(Material.Specular, TexCoords).rgb;

  return Ambient + Diffuse + Specular;
}

// FUNCION QUE CALCULA EL MODELO DE REFLEXION DE PHONG PARA LUCES DIRECCIONALES
/*vec3 PhongLuzDireccional (TLuzDireccional light, vec3 n, vec3 v)
{
  // CALCULAR LOS DIFERENTES VECTORES
  vec3 s = normalize(light.Position - Position);
  vec3 r = reflect(-s, n);

  // COMPONENTE AMBIENTAL
  vec3 Ambient = light.Intensity * vec3(texture(Material.Diffuse, TexCoords));
  //vec3 Ambient = light.Intensity * texture(Material.Diffuse, TexCoords).rgb;

  // COMPONENTE DIFUSA
  vec3 Diffuse = light.Intensity * max(dot(s, n), 0.0) * vec3(texture(Material.Diffuse, TexCoords));
  //vec3 Diffuse = light.Intensity * max(dot(s, n), 0.0) * texture(Material.Diffuse, TexCoords).rgb;

  // COMPONENTE ESPECULAR
  vec3 Specular = light.Intensity * pow(max(dot(r, v), 0.0), Material.Shininess) * vec3(texture(Material.Specular, TexCoords));
  //vec3 Specular = light.Intensity * pow(max(dot(r, v), 0.0), Material.Shininess) * texture(Material.Specular, TexCoords).rgb;

  return Ambient + Diffuse + Specular;
}*/

void main()
{
  /*
  vec3 diffuse = texture(Material.Diffuse, TexCoords).rgb;
  //vec3 height = texture(texture_height, texCoords).rgb;
  vec3 metalness = texture(Material.Specular, TexCoords).rgb;
  //vec3 normal = texture(texture_normal, texCoords).rgb;
  //vec3 roughness = texture(texture_roughness, texCoords).rgb;
  vec3 result = diffuse + metalness;

  FragColor = vec4(result, 1.0);
  */

  vec3 result = vec3(0.0);
  int cont = 0;

  //vec3 normal = texture(Material.Normal, TexCoords).rgb;
  //normal = normalize(normal * 2.0 - 1.0);
  //normal = normal * Normal;
  //vec3 height = normalize(texture(Material.Height, TexCoords).rgb * 2.0 - 1.0);
  //vec3 pos = Position * height;

  vec3 n = normalize(Normal);
  vec3 v = normalize(ViewPos - Position);

  // LUCES PUNTUALES
  while(cont < numLucesPuntuales) {
    result += PhongLuzPuntual(LucesPuntuales[cont], n, v);
    cont++;
  }

  // If we're drawing an edge, use constant color,
  // otherwise, shade the poly.
  /*if(GIsEdge == 1.0) {
    FragColor = LineColor;
  }

  else {*/
    FragColor = vec4(result, 1.0);
    //FragColor = floor(FragColor * cartoonParts) / cartoonParts;
  //}
  
}
