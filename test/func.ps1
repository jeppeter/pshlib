function Print-Number($ncc,$cc)
{
    echo "Number is $ncc,$cc";
}

function Do-Loop($function,$argv)
{
    $numbers = 1..3
    foreach ($n2 in $numbers)
    {
        Invoke-Command $function -ArgumentList $n2,$argv
    }    
}

Do-Loop ${function:\Print-Number} -argv 32