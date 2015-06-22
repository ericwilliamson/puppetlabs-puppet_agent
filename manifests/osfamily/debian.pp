class puppet_agent::osfamily::debian {
  include apt

  apt::conf { 'pc1_repo':
    content => "Acquire::https::dev.example.vm::Verify-Peer false;\nAcquire::http::Proxy::dev.example.vm DIRECT;",
  }


  apt::source { 'pc1_repo':
    location   => $::puppet_agent::_source,
    repos      => 'PC1',
    key        => {
      'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      'server' => 'pgp.mit.edu',
    }
  }
}
