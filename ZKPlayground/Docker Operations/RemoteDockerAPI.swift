//
//  RemoteDockerAPI.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/23/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

/// Just leaving this here in case we want to control Docker remotely
/// Source: https://github.com/docker/for-mac/issues/770
/// https://github.com/valeriomazzeo/docker-client-swift
/// https://docs.docker.com/develop/sdk/examples/
class RemoteDockerAPI: Operation {
    
    let command = "docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 127.0.0.1:1234:1234 bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock; export DOCKER_HOST=tcp://localhost:1234"
    // curl 127.0.0.1:1234/containers/json
    
}
