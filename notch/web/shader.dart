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