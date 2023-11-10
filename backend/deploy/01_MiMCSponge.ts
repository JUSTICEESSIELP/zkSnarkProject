import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const MiMCSponge: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
  run,
}) {
  // code here
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("Hasher", {
    from: deployer,
    args: [],
    log: true,
  });
};
export default MiMCSponge;

MiMCSponge.tags = ["MiMC", "all"];
