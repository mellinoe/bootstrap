usage()
{
    echo "builds a bootstrap CLI from sources"
}

__buildArch=
__rid=

while [ "$1" != "" ]; do
        lowerI="$(echo $1 | awk '{print tolower($0)}')"
        case $lowerI in
        -h|--help)
            usage
            exit 1
            ;;
        --arch)
            shift
            __build_arch=$1
            ;;
        --rid)
            shift
            __runtime_id=$1
            ;;
        *)
        echo "Unknown argument to build.sh $1"; exit 1
    esac
    shift
done


core-setup/src/corehost/build.sh --arch $__build_arch --rid $__runtime_id --hostver 1.0.2 --fxrver 1.0.2 --policyver 1.0.2 --commithash ff2908e099bbe6beac1f51afe37c9d176fb170e4
