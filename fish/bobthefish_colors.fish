function bobthefish_colors -S -d 'Gruvbox Material'

  # Optionally include a base color scheme
  __bobthefish_colors gruvbox

  #               light  medium  dark  darkest
  #               ------ ------ ------ -------
  set -l red      4c3432 402120
  set -l green    3b4439 34381b a9b665
  set -l yellow   d8a657 c18f41
  set -l aqua     89b482 72966c
  set -l blue     374141 0e363e
  set -l grey     a89984 928374 7c6f64
  set -l purple   d3869b ab6c7d
  set -l fg       ddc7a1 d4be98 c5b18d
  set -l bg       5a524c 45403d 302f2e 282828

  set -x color_initial_segment_exit     $fg[1] $red[2] --bold
  set -x color_initial_segment_private  $fg[1] $bg[1]
  set -x color_initial_segment_su       $fg[1] $green[2] --bold
  set -x color_initial_segment_jobs     $fg[1] $aqua[2] --bold

  set -x color_path                     $bg[4] $fg[2]
  set -x color_path_basename            $bg[4] $fg[2] --bold
  set -x color_path_nowrite             $red[1] $fg[2]
  set -x color_path_nowrite_basename    $red[1] $fg[2] --bold

  set -x color_repo                     $green[3] $bg[1]
  set -x color_repo_work_tree           $bg[1] $fg[2] --bold
  set -x color_repo_dirty               $red[2] $fg[2]
  set -x color_repo_staged              $yellow[1] $bg[1]

  set -x color_vi_mode_default          $fg[4] $bg[2] --bold
  set -x color_vi_mode_insert           $blue[1] $bg[2] --bold
  set -x color_vi_mode_visual           $yellow[1] $bg[2] --bold

  set -x color_vagrant                  $blue[2] $fg[2] --bold
  set -x color_k8s                      $green[2] $fg[2] --bold
  set -x color_aws_vault                $blue[2] $yellow[1] --bold
  set -x color_aws_vault_expired        $blue[2] $red[1] --bold
  set -x color_username                 $fg[3] $blue[2] --bold
  set -x color_hostname                 $fg[3] $blue[2]
  set -x color_rvm                      $red[2] $fg[2] --bold
  set -x color_node                     $green[1] $fg[2] --bold
  set -x color_virtualfish              $bg[2] $fg[2] --bold
  set -x color_virtualgo                $bg[2] $fg[2] --bold
  set -x color_desk                     $bg[2] $fg[2] --bold
  set -x color_nix                      $bg[2] $fg[2] --bold
end
