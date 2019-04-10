set -e

repo=$1
branch=$2
tag=$3
out=$4

if commit=$(git -C "$repo" show-ref -s --verify "refs/heads/$branch" 2>/dev/null) ; then
	oldtree=$(git -C "$repo" rev-parse --verify "$branch^{tree}")
	newtree=$(git -C "$repo" rev-parse --verify "$tag^{tree}")
	if [ "$oldtree" != "$newtree" ] ; then
		set -- -p "$branch"
		unset commit
	fi
else
	set --
fi

if [ -z "${commit+set}" ] ; then
	commit=$(git -C "$repo" commit-tree -m "oasis built by $(id -un)" "$@" "$tag")
	git -C "$repo" update-ref "refs/heads/$branch" "$commit"
fi
echo "$commit" >"$out.tmp" && mv "$out.tmp" "$out"
