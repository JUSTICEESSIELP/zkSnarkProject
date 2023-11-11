import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, DeployedContract } from "hardhat-deploy/types";

const Verifier: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
  run,
}) {
  // code here
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("Groth16Verifier", {
    from: deployer,
    args: [],
    log: true,
  });
};
export default Verifier;

Verifier.tags = ["Verifier", "all"];
