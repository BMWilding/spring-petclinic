# Remove old images 
remove_old_nexus_images:
  docker_image.absent:
    - images:
        - sonatype/nexus:2.11.0
        - sonatype/nexus:2.10.0
nexus:
  host.present:
    - ip: 127.0.0.1
