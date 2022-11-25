// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    address owner;
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address _owner, address spender) public view virtual override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 value) public virtual override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        if(owner == account){
            _totalSupply = _totalSupply.add(amount);
        }
        
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function burn(uint256 _value) public{
        
        _burn(msg.sender,_value);
    }

    function _approve(address _owner, address spender, uint256 value) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

contract ERC20Detailed  {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory __name, string memory __symbol, uint8 __decimals)  {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Arbitech is ERC20, ERC20Detailed {
    using SafeMath for uint256;

   
    uint256 public Duration = 54 minutes ; 
    uint256 public _currentSupply;
    uint256 public slotTime = 1 minutes;
    uint256 public deployTime;
    uint256 public reward;
    uint256 public TotalSupply;
    uint256 public tokenAmount;
    uint256 public RemainingSupply;
    uint256 public _D;
    
    constructor () ERC20Detailed("Arbitech Solution", "ArbiCoin",18) {

        deployTime = block.timestamp;
        owner=msg.sender;
        _mint(owner,(1000*(10**18)));
        _mint(address(this), 54000*(10**18));
        TotalSupply = balanceOf(address(this));
        _currentSupply = balanceOf(address(this));
        Duration= Duration.div(60);
    }


    modifier onlyOwner(address _owner){
        require(msg.sender == owner && owner == _owner,"not a owner!");
        _;
    }

    function Mint(address _user, uint256 amount) public{

        require(owner == msg.sender, "You are not owner!");
        _mint(_user,(amount));
    }
   
    function calculateTime() public view returns (uint256) {

        uint256 totalTime;
        totalTime = (block.timestamp.sub(deployTime)).div(slotTime);
        return totalTime;
    }

    // function ChangeStatus(bool TorF) public {
    //     status = TorF;
    // }

    function TokenCalculations() public view returns(uint256){
      
        uint256 calcTime = calculateTime();
        uint256  _Duration; 
        uint256  _calcTime;
        uint256  _calcTime1;
        uint256  TokenPerMinutes;
        uint256  _reward;
        uint256  Supply;
       
        _calcTime = calcTime.sub(_calcTime1);
        _calcTime1 = _calcTime1.add(_calcTime);
       
        Supply = TotalSupply.sub(_reward);
        TokenPerMinutes = Supply.div(Duration).div(1 ether);
        _Duration = Duration.sub(_calcTime1);
        _reward +=  (_calcTime.mul(TokenPerMinutes));
       
        return _reward.sub(reward);            
    }
   
    function TokenCalculateByOwner(uint256 _tokenAmount) public {
        withdraw(msg.sender);
        uint256 time_ = calculateTime();
       // uint256 time_ = 0;
        tokenAmount= _tokenAmount;
        RemainingSupply = _currentSupply;
        _D = (RemainingSupply.div(_tokenAmount));//tokenperminutebyowner
        Duration = (time_.add(_D)); //time + 

    }

    function withdraw(address _owner) public onlyOwner(_owner) {
        uint256 transferReward = TokenCalculations();
        reward += transferReward;
        require(reward <= balanceOf(address(this)), "Not enough balance!");
        Mint(_owner, transferReward);
        _currentSupply -= transferReward;
       
    }
    
}
