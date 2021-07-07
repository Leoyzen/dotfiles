function bobthefish_colors -S -d 'Gruvbox Material Mix'

  # Optionally include a base color scheme
  __bobthefish_colors gruvbox

  #               light  medium  dark  darkest
  #               ------ ------ ------ -------
  set -l red      f2594b db4740 442e2d 3c1f1e
  set -l green    b0b846 3b4439 34381b
  set -l orange   f28534
  set -l yellow   e9b143 
  set -l aqua     8bba7f 89b482 72966c 
  set -l blue     80aa9e 374141 0e363e
  set -l grey     a89984 928374 7c6f64
  set -l purple   d3869b ab6c7d
  set -l fg       e2cca9 e2cca9
  set -l bg       5a524c 45403d 302f2e 282828

  set -x color_initial_segment_exit     $fg[1] $red[2] --bold
  set -x color_initial_segment_private  $fg[1] $bg[1]
  set -x color_initial_segment_su       $fg[1] $green[2] --bold
  set -x color_initial_segment_jobs     $fg[1] $purple[1] --bold

  set -x color_path                     $bg[3] $fg[2]
  set -x color_path_basename            $bg[3] $fg[2] --bold
  set -x color_path_nowrite             $red[4] $fg[2]
  set -x color_path_nowrite_basename    $red[4] $fg[2] --bold

  set -x color_repo                     $green[1] $bg[1]
  set -x color_repo_work_tree           $bg[1] $fg[2] --bold
  set -x color_repo_dirty               $orange[1] $bg[2]
  set -x color_repo_staged              $yellow[1] $bg[1]

  set -x color_vi_mode_default          $fg[4] $bg[2] --bold
  set -x color_vi_mode_insert           $blue[1] $bg[2] --bold
  set -x color_vi_mode_visual           $orange[1] $bg[2] --bold

  set -x color_vagrant                  $blue[2] $fg[2] --bold
  set -x color_k8s                      $green[2] $fg[2] --bold
  set -x color_aws_vault                $blue[2] $yellow[1] --bold
  set -x color_aws_vault_expired        $blue[2] $red[2] --bold
  set -x color_username                 $fg[1] $bg[1] --bold
  set -x color_hostname                 $fg[1] $bg[1]
  set -x color_rvm                      $red[2] $fg[2] --bold
  set -x color_node                     $green[1] $fg[2] --bold
  set -x color_virtualfish              $bg[2] $fg[2] --bold
  set -x color_virtualgo                $bg[2] $fg[2] --bold
  set -x color_desk                     $bg[3] $fg[3] --bold
  set -x color_nix                      $bg[3] $fg[3] --bold
end
