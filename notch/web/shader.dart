part of notch;

class Shader {
  String vertexShaderCode;
  String fragmentShaderCode;
  GL.Shader vertexShader;
  GL.Shader fragmentShader;
  GL.Program program;
  
  Shader(this.vertexShaderCode, this.fragmentShaderCode) {
    compile();
  }
  
  void compile() {
    vertexShader = gl.createShader(GL.VERTEX_SHADER);
    gl.shaderSource(vertexShader, vertexShaderCode);
    gl.compileShader(vertexShader);
    if (!gl.getShaderParameter(vertexShader, GL.COMPILE_STATUS)) {
      throw gl.getShaderInfoLog(vertexShader);
    }
    
    fragmentShader = gl.createShader(GL.FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, fragmentShaderCode);
    gl.compileShader(fragmentShader);
    if (!gl.getShaderParameter(fragmentShader, GL.COMPILE_STATUS)) {
      throw gl.getShaderInfoLog(fragmentShader);
    }
    
    program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, GL.LINK_STATUS)) {
      throw gl.getProgramInfoLog(program);
    }
  }
}

Shader quadShader = new Shader("""
  precision highp float;

  attribute vec3 a_pos;

  uniform mat4 u_objectTransform;
  uniform mat4 u_cameraTransform;
  uniform mat4 u_viewTransform;
  uniform mat4 u_textureTransform;

  varying vec2 v_texcoord;
  varying float v_dist;

  void main() {
    v_texcoord = (u_textureTransform * vec4(a_pos, 1.0)).xy;
    vec4 pos = u_viewTransform * u_cameraTransform * u_objectTransform * vec4(a_pos, 1.0);
    v_dist = pos.z;
    gl_Position = pos;
  }
""", """
  precision highp float;

  varying vec2 v_texcoord;
  varying float v_dist;

  uniform vec4 u_color;
  uniform sampler2D u_tex;

  void main() {
    vec4 col = texture2D(u_tex, v_texcoord);
    if (col.a > 0.0) {
      gl_FragColor = vec4((col * u_color).xyz / (v_dist * 4.0 + 1.0), 1.0);
    } else {
      discard;
    }
  }
""");

