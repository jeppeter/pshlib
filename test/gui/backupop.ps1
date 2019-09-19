
function backup_temp($newdir,$copied,$removed,$regsetted)
{
    $diffed = 0;
    $vn = _get_shellval_setted_keyname -keyname "temp";
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "environment [temp] has already setted";
        return -3;
    }

    $tempval = get_env_value -keyname "temp";
    $vn = _get_shell_value_keyname -keyname "temp";
    $c = set_value_global -varname $vn -varvalue $tempval;
    $vn = _get_shellval_setted_keyname -keyname "temp";
    $c = set_value_global -varname $vn -varvalue "1";

    $tmpval = get_env_value -keyname "tmp";
    $vn = _get_shellval_setted_keyname -keyname "tmp";
    $c = set_value_global -varname $vn -varvalue $tmpval;
    $vn = _get_shellval_setted_keyname -keyname "tmp";
    $c = set_value_global -varname $vn -varvalue "1";

    $extmpval= "";
    $extempval = "";

    if (-Not [string]::IsNullOrEmpty($tmpval) -And -Not [string]::IsNullOrEmpty($tempval)) {
        $extmpval = [System.Environment]::ExpandEnvironmentVariables($tmpval);
        $extempval = [System.Environment]::ExpandEnvironmentVariables($tempval);
        if (-Not $extmpval.Equals($extempval)) {
            write_stderr -msg "[TMP].[$extmpval] != [TEMP].[$extempval]";
            return -5;
        }
    } elseif (-Not [string]::IsNullOrEmpty($tmpval)) {
        $extmpval = [System.Environment]::ExpandEnvironmentVariables($tmpval);
    } elseif (-Not [string]::IsNullOrEmpty($tempval)) {
        $extmpval = [System.Environment]::ExpandEnvironmentVariables($tempval);
    }

    if (-Not [string]::IsNullOrEmpty($extmpval)) {
        if (-Not $newdir.Equals($extmpval)) {
            # now we should give the compare
            if ($removed) {
                $retval = add_task_keyname -keyname "temp" -dir $extmpval;
            } else {
                $retval = add_task_keyname_empty -keyname "temp";
            }
            if ($retval -lt 0) {
                return $retval;
            }                


            if ($copied) {
                $retval = copy_dir_top -srcdir $extmpval -dstdir $newdir;
                if ($retval -lt 0) {
                    return -3;
                }
            }
            $diffed = 1;
        }
    } else {
        $retval = make_dir_safe -dir $newdir;
        if ($retval -ne 0) {
            return -6;
        }
        $retval = add_task_keyname_empty -keyname "temp";
        if ($retval -lt 0) {
            return $retval;
        }

        $diffed = 1;
    }

    if ($diffed) {
        $vn = _get_newdir_keyname -keyname "temp";
        set_value_global -varname $vn -varvalue $newdir;


        if ($regsetted) {
            $retval = set_env_value -keyname "temp" -value $newdir;
            if ($retval -ne 0) {
                return -6;
            }

            $retval = set_env_value -keyname "tmp" -value $newdir;
            if ($retval -ne 0) {
                return -7;
            }            
        }
    }


    return $diffed;
}


function restore_temp()
{

    $c = remove_task_keyname -keyname "temp";

    $vn = _get_shellval_setted_keyname -keyname "temp";
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have setted
        $vn = _get_shell_value_keyname -keyname "temp";
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_env_value -keyname "temp";
        } else {
            set_env_value -keyname "temp" -value $v;
        }
        $vn = _get_shellval_setted_keyname -keyname "temp";
        set_value_global -varname $vn -varvalue "";
    }


    $vn = _get_shellval_setted_keyname -keyname "tmp";
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have setted
        $vn = _get_shell_value_keyname -keyname "tmp";
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_env_value -keyname "tmp";
        } else {
            set_env_value -keyname "tmp" -value $v;
        }
        $vn = _get_shellval_setted_keyname -keyname "tmp";
        set_value_global -varname $vn -varvalue "";
    }

    $vn = _get_newdir_keyname -keyname "temp";
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        $c = remove_dir -dir $v;
        $c = set_value_global -varname $vn -varvalue "";
    }
    return;
}



function backup_spec($keyname,$itemname,$newdir,$copied,$removed,$regsetted)
{
    write_stdout -msg "keyname[$keyname] itemname[$itemname] newdir[$newdir]";
    $diffed = 0;


    $vn = _get_shellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "already set [$keyname]";
        return -3;
    }

    $shellval = get_shell_folder_value -keyname $itemname;
    write_stdout -msg "shell[$keyname].[$itemname]=[$shellval]";
    $vn = _get_shell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $shellval;
    $vn = _get_shellval_setted_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue "1";

    $usershellval = get_user_shell_folder_value -keyname $itemname;
    write_stdout -msg "usershell[$keyname].[$itemname]=[$shellval]";
    $vn = _get_usershell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $usershellval;
    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue "1";




    $exshellval = "";
    $exusershellval = "";

    if ( -Not [string]::IsNullOrEmpty($shellval)  -And -Not [string]::IsNullOrEmpty($usershellval)) {
        $exshellval = [System.Environment]::ExpandEnvironmentVariables($shellval);
        $exusershellval = [System.Environment]::ExpandEnvironmentVariables($usershellval);
        if (-Not $exshellval.Equals($exusershellval)) {
            write_stderr -msg "keyname[$keyname].item[$itemname] usershell[$usershellval] != shellval[$shellval]";
            return -3;
        }
    } elseif (-Not [string]::IsNullOrEmpty($shellval)) {
        $exshellval = [System.Environment]::ExpandEnvironmentVariables($shellval);
    } elseif (-Not [string]::IsNullOrEmpty($usershellval)) {
        $exshellval = [System.Environment]::ExpandEnvironmentVariables($usershellval);
    }

    if (-Not [string]::IsNullOrEmpty($exshellval)) {
        if (-Not $exshellval.Equals($newdir)) {

            if ($removed) {
                $retval = add_task_keyname -keyname $keyname -dir $exshellval;                
            } else {
                $retval = add_task_keyname_empty -keyname $keyname;
            }
            if ($retval -lt 0) {
                return $retval;
            }

            # now to copy 
            if ($copied) {
                $retval = copy_dir_top -srcdir $exshellval -dstdir $newdir;
                if ($retval -lt 0) {
                    return -7;
                }                
            }
            $diffed=1;
        }
    } else {
        $retval = make_dir_safe -dir $newdir;
        if ($retval -ne 0) {
            return -3;
        }

        $retval = add_task_keyname_empty -keyname $keyname;
        if ($retval -lt 0) {
            return -5;
        }
        $diffed=1;
    }

    if ($diffed) {
        $vn = _get_newdir_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue $newdir;

        if ($regsetted) {
            $retval = set_shell_folder_value -keyname $itemname -value $newdir;
            if ($retval -ne 0) {
                return -6;
            }

            $retval = set_user_shell_folder_value -keyname $itemname -value $newdir;
            if ($retval -ne 0) {
                return -7;
            }            
        }
    }
    return $diffed;
}


function restore_spec($keyname,$itemname)
{
    $vn = _get_rmtask_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have set
        remove_once_task -taskname $v;
        # we do not remove it double
        set_value_global -varname $vn -varvalue "";
    }


    $vn = _get_shellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have setted
        $vn = _get_shell_value_keyname -keyname $keyname;
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_shell_folder_value -keyname $itemname;
        } else {
            set_shell_folder_value -keyname $itemname -value $v;
        }
        $vn = _get_shellval_setted_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue "";
    }


    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        $vn = _get_usershell_value_keyname -keyname $keyname;
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_user_shell_folder_value -keyname $itemname;
        } else {
            set_user_shell_folder_value -keyname $itemname -value $v;
        }
        $vn = _get_usershellval_setted_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue "";
    }

    $vn = _get_newdir_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        $c = remove_dir -dir $v;
        $c = set_value_global -varname $vn -varvalue "";
    }
    return;
}


function backup_directory($keyname,$newdir,$copied,$removed)
{
    write_stdout -msg "keyname [$keyname] newdir [$newdir]";
    $diffed = 0;
    $vn = _get_shellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "[$keyname] has already done";
        return -2;
    }

    write_stdout -msg " ";

    $shellval = get_shell_folder_value -keyname $keyname;
    $vn = _get_shell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $shellval;
    $vn = _get_shellval_setted_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue "1";

    write_stdout -msg " ";
    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "[$keyname] has already done";
        return -2;
    }
    write_stdout -msg " ";

    $usershellval = get_user_shell_folder_value -keyname $keyname;
    $vn = _get_usershell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $usershellval;
    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    set_value_global -varname $vn =varvalue "1";

    write_stdout -msg " ";

    $exshellval = "";

    if (-Not [string]::IsNullOrEmpty($usershellval) -And -Not [string]::IsNullOrEmpty($shellval)) {
        $exshellval = [System.Environment]::ExpandEnvironmentVariables($shellval);
        $exusershellval = [System.Environment]::ExpandEnvironmentVariables($usershellval);
        if (-Not $exusershellval.Equals($exshellval)) {
            write_stderr -msg "usershellval[$keyname][$usershellval] != shellval[$keyname][$shellval]";
            return -3;
        }

    } elseif (-Not [string]::IsNullOrEmpty($usershellval) -Or -Not [string]::IsNullOrEmpty($shellval)) {
        write_stderr -msg "usershellval[$keyname][$usershellval] != shellval[$keyname][$shellval]";
        return -2;
    }


    write_stdout -msg " ";
    # now we should copy the directory
    if ([string]::IsNullOrEmpty($exshellval)) {
        $retval = make_dir_safe -dir $newdir;
        if ($retval -ne 0) {
            write_stderr -msg " ";
            return -3;
        }
        $retval = add_task_keyname_empty -keyname $keyname;
        if ($retval -lt 0) {
            write_stderr -msg " ";
            return $retval;
        }
        $diffed = 1;
    } else {
        if(-Not $exshellval.Equals($newdir)) {
            if ($copied) {
                $retval = copy_dir_top -srcdir $exshellval -dstdir $newdir;
                if ($retval -lt 0) {
                    write_stderr -msg " ";
                    return -3;
                }                
            }

            if ($removed) {
                $retval = add_task_keyname -keyname $keyname -dir $exshellval;
            } else {
                $retval = add_task_keyname_empty -keyname $keyname;
            }
            if ($retval -lt 0) {
                write_stderr -msg " ";
                return $retval;
            }

            $diffed = 1;
        }        
    }
    write_stdout -msg " ";

    if ($diffed) {
        $vn = _get_newdir_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue $newdir;

        if ($regsetted) {
            $retval = set_shell_folder_value -keyname $keyname -value $newdir;
            if ($retval -ne 0) {
                return -6;
            }

            $retval = set_user_shell_folder_value -keyname $keyname -value $newdir;
            if ($retval -ne 0) {
                return -7;
            }
        }
    }
    write_stdout -msg " ";

    return $diffed;
}

function restore_directory($keyname)
{
    # first to get the taskname 
    $vn = _get_rmtask_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have set
        remove_once_task -taskname $v;
        # we do not remove it double
        set_value_global -varname $vn -varvalue "";
    }

    $vn = _get_shellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have setted
        $vn = _get_shell_value_keyname -keyname $keyname;
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_shell_folder_value -keyname $keyname;
        } else {
            set_shell_folder_value -keyname $keyname -value $v;
        }
        $vn = _get_shellval_setted_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue "";
    }

    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        $vn = _get_usershell_value_keyname -keyname $keyname;
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_user_shell_folder_value -keyname $keyname;
        } else {
            set_user_shell_folder_value -keyname $keyname -value $v;
        }
        $vn = _get_usershellval_setted_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue "";
    }


    # now to make new directory
    $vn = _get_newdir_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        $v = remove_dir -dir $v;
        $v = set_value_global -varname $vn -varvalue "";
    }
    return;
}
