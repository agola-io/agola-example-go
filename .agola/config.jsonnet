local go_runtime(version, arch) = {
  type: 'pod',
  arch: arch,
  containers: [
    { image: 'golang:' + version + '-stretch' },
  ],
};

local task_build_go(version, arch) = {
  name: 'build go ' + version + ' ' + arch,
  runtime: go_runtime(version, arch),
  steps: [
    { type: 'clone' },
    { type: 'restore_cache', keys: ['cache-sum-{{ md5sum "go.sum" }}', 'cache-date-'], dest_dir: '/go/pkg/mod/cache' },
    { type: 'run', name: 'build the program', command: 'go build .' },
    { type: 'save_to_workspace', contents: [{ source_dir: '.', dest_dir: '/bin/', paths: ['agola-example-go'] }] },
    { type: 'save_cache', key: 'cache-sum-{{ md5sum "go.sum" }}', contents: [{ source_dir: '/go/pkg/mod/cache' }] },
    { type: 'save_cache', key: 'cache-date-{{ year }}-{{ month }}-{{ day }}', contents: [{ source_dir: '/go/pkg/mod/cache' }] },
  ],
};

{
  runs: [
    {
      name: 'agola go example',
      tasks: [
        task_build_go(version, arch)
        for version in ['1.11', '1.12']
        # uncomment additional archs if there's an available executor
        for arch in ['amd64' /*'arm64'*/]
      ] + [
        {
          name: 'run',
          runtime: {
            type: 'pod',
            arch: 'amd64',
            containers: [
              { image: 'debian:stretch' },
            ],
          },
          steps: [
            { type: 'restore_workspace', dest_dir: '.' },
            { type: 'run', command: './bin/agola-example-go' },
          ],
          depends: [
            'build go 1.12 amd64',
          ],
        },
      ],
    },
  ],
}
