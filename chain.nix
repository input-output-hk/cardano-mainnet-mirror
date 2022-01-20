# $ for x in {000..020}; do tar -cf ${x}.tar immutable/${x}* ; time pigz -9v ${x}.tar ; echo ${x}; done
# manually delete any file that does not have a complete set of 100 chunks
# $ s3cmd put *.tar.gz s3://cardano-mainnet-chain

{ fetchzip, lib, buildEnv, runCommand, upToChunk ? null }:

let
  hashes = [
    { prefix = "000"; hash = "sha256-WCgoEVOSnmMILS7OsjIVB6AkGJcHxBdM26jQLAWAq18="; }
    { prefix = "001"; hash = "sha256-2QChj5WMbjBI/hQsdDI18LrMs6oKgbLViofl/5eOzgI="; }
    { prefix = "002"; hash = "sha256-/MsrZPGlUVjkacjzv8maHSFkRt3NMYS8KvERuj8KFiI="; }
    { prefix = "003"; hash = "sha256-zrqZIzj+h5sB9O/zXVySWwXR+OnU1KjqB16FZ2lL+/4="; }
    { prefix = "004"; hash = "sha256-c34ivJQsAT0DFDW4d9yYaR3bt4mQnsljePpEfhvgbuM="; }
    { prefix = "005"; hash = "sha256-xOOBPaH1Cxk8T15mkBrNOR79M+ohHEOZ9OSqW97FWgI="; }
    { prefix = "006"; hash = "sha256-ExDG+9mSdWv2+1u+1X3d/Wo6SXUTrOcpUFdfSOBenL0="; }
    { prefix = "007"; hash = "sha256-2EYPglFSE06X3+swm7TNJeDu5kuBH4YmzQPS+LkGpF4="; }
    { prefix = "008"; hash = "sha256-JDSzdKJGEr1l14HsdCckFH/9+ibuigU+/JuH1SpYNuE="; }
    { prefix = "009"; hash = "sha256-VVf65OAwadCs9hVJ2pK4uULg5MjdRhvUIfbUMKWtBPY="; }
    { prefix = "010"; hash = "sha256-hBG5O4eIMm1MWeVrWzfWblmRm2xS+7+EYMa8JgIk+6w="; }
    { prefix = "011"; hash = "sha256-4qh2cW7o5PiUtX5AND6PLjXizkfvHcYXHgW3fzxsEQo="; }
    { prefix = "012"; hash = "sha256-avZOmYuSoxJwmanwAcYkXu4zDu7RbG9QvU5R4HJ7FNk="; }
    { prefix = "013"; hash = "sha256-838/gJm6ggkGjT72agcM98twZ+DvlL7U1az1DMDX2VM="; }
    { prefix = "014"; hash = "sha256-nNNuOBNaCZofOylaaQXng9NEs5EEEDxIaM7naJ2FeHs="; }
    { prefix = "015"; hash = "sha256-MJYuYHYAHLookWxRnVb3r7mXzmPMfosb2Ed2M4ppVF8="; }
    { prefix = "016"; hash = "sha256-Wl0PezrjB7qAwNd7DtEXGEzEHXPxP7YF/c4PLJUbuIU="; }
    { prefix = "017"; hash = "sha256-v/8Wc4NL7nqRavFlOafJ1cnAlzV4iV1mOUzVUA/4z7Y="; }
    { prefix = "018"; hash = "sha256-z7jcDGmgR6XMwCpOECeHjS5UBfZY5fiZqM1gNODGP0M="; }
  ];
  fetchpart = { prefix, hash }:
  fetchzip {
    name = "chain-part-${prefix}";
    url = "https://cardano-mainnet-chain.s3.eu-central-1.amazonaws.com/${prefix}.tar.gz";
    sha256 = hash;
  };
  filterUpTo = hash:
  let
    sansPrefix = lib.removePrefix "0" (lib.removePrefix "0" hash.prefix);
    chunkPrefix = builtins.fromJSON sansPrefix;
  in
    chunkPrefix <= (upToChunk / 100);
  f = if upToChunk == null then (_: true) else filterUpTo;
  immutable = buildEnv {
    name = "chain";
    paths = map fetchpart (lib.filter f hashes);
  };
  mainnetProtocolMagic = 764824073;
in runCommand "chain" {
  requiredSystemFeatures = [ "benchmark" ];
} ''
  mkdir $out
  cd $out
  ln -sv ${immutable} immutable
  echo ${toString mainnetProtocolMagic} > protocolMagicId
''
