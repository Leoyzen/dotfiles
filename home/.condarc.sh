# This is a sample .condarc file. It adds the r Anaconda.org channel and enables
# the show_channel_urls option.

# channel locations. These override conda defaults, i.e., conda will
# search *only* the channels listed here, in the order given. Use "defaults" to
# automatically include all default channels. Non-url channels will be
# interpreted as Anaconda.org usernames (this can be changed by modifying the
# channel_alias key; see below). The default is just 'defaults'.
channels:
  # - http://mirrors.aliyun.com/pypi/simple/
  # - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  # - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r/
  # - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/mro/
  # - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro/
  # - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
  # - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
  # - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/
  - defaults
  - menpo
  - conda-forge
    #- trentonoliphant
    #- activisiongamescience

# Show channel URLs when displaying what is going to be downloaded and
# in 'conda list'. The default is False.
show_channel_urls: true

create_default_packages:
  - ipython
  - numpy
  - pandas
  # - matplotlib

always_yes: true


# See http://conda.pydata.org/docs/install/config.html for more information about this file.
# proxy_servers:
  # http: http://localhost:4411
    # https: https://localhost:8032
