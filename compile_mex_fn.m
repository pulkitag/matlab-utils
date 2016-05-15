function [] = compile_mex_fn(fnName)
  mex -v CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp"
end
