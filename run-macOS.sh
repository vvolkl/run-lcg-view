#!/bin/zsh

set -e

echo "::group::Launching container"

if [ -z "${VIEW_PATH}" ]; then
  echo "Checking if there is a working CVMFS mount"

  if [ ! -d "/Users/Shared/cvmfs/sft.cern.ch/lcg/" ]; then
    echo "The directory /Users/Shared/cvmfs/sft.cern.ch/lcg cannot be accessed!"
    echo "Make sure you are using the cvmfs-contrib/github-action-cvmfs@v5 action or later"
    echo "and that you have set cvmfs_repositories: 'sft.cern.ch,geant4.cern.ch'."
    echo "There is no automount on macOS."
    exit 1
  fi

  if [ ! -d "/Users/Shared/cvmfs/geant4.cern.ch/share/" ]; then
    echo "The directory /Users/Shared/cvmfs/geant4.cern.ch/share/ cannot be accessed!"
    echo "Make sure you are using the cvmfs-contrib/github-action-cvmfs@v5 action or later"
    echo "and that you have set cvmfs_repositories: 'sft.cern.ch,geant4.cern.ch'."
    echo "There is no automount on macOS."
    exit 1
  fi

  echo "CVMFS mount present"

  VIEW_PATH="/Users/Shared/cvmfs/sft.cern.ch/lcg/views/${LCG_RELEASE_PLATFORM}"
  if [[ "${LCG_RELEASE}" == *"dev"* ]]; then

  if [ ! -d "/Users/Shared/cvmfs/sft-nightlies.cern.ch/lcg/" ]; then
    echo "The directory /Users/Shared/cvmfs/sft.cern.ch/lcg cannot be accessed!"
    echo "Make sure you are using the cvmfs-contrib/github-action-cvmfs@v5 action or later"
    echo "and that you have set cvmfs_repositories: 'sft.cern.ch,geant4.cern.ch'."
    echo "There is no automount on macOS."
    exit 1
  fi
    VIEW_PATH="/Users/Shared/cvmfs/sft-nightlies.cern.ch/lcg/views/${LCG_RELEASE}/latest/${LCG_PLATFORM}"
  fi
fi

echo "Installing view prerequisites:"
#brew install ninja
#brew install gfortran
#brew install --cask xquartz
echo "Installation done."

echo "Full view path is ${VIEW_PATH}"

df -h
cvmfs_config chksetup || true
ls /cvmfs/sft-nightlies.cern.ch
ls /Users/Shared/cvmfs/sft-nightlies.cern.ch
ls /Users/Shared/cvmfs/sft-nightlies.cern.ch/lcg
ls /Users/Shared/cvmfs/sft-nightlies.cern.ch/lcg/views/
ls /Users/Shared/cvmfs/sft-nightlies.cern.ch/lcg/views/dev4
ls /Users/Shared/cvmfs/sft-nightlies.cern.ch/lcg/views/dev4/latest/

ls ${VIEW_PATH}

if [ ! -d "${VIEW_PATH}" ]; then
  echo "Did not find a view under this path!"
  exit 1
fi

echo "#!/bin/zsh

set -e

source ${VIEW_PATH}/${SETUP_SCRIPT}
cd ${GITHUB_WORKSPACE}

${RUN}
" > ${GITHUB_WORKSPACE}/action_payload.sh
chmod a+x ${GITHUB_WORKSPACE}/action_payload.sh

echo "::endgroup::" # Launch container

echo "####################################################################"
echo "###################### Executing user payload ######################"
echo "VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV"

cd ${GITHUB_WORKSPACE}
./action_payload.sh
