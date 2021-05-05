pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "./utils/Initializable.sol";

import "./utils/SafeMathUpgradeable.sol";

import "./interfaces/IGETAccessControl.sol";
import "./interfaces/IEconomicsGET.sol";

contract eventMetadataStorage is Initializable {
    IGETAccessControl public GET_BOUNCER;
    IEconomicsGET public ECONOMICS;

    using SafeMathUpgradeable for uint256;

    struct EventStruct {
        address event_address; 
        address integrator_address;
        address underwriter_address;
        string event_name;
        string shop_url;
        string image_url;
        // bytes[2] event_urls; // [bytes shopUrl, bytes eventImageUrl]
        bytes32[4] event_metadata; // -> [bytes32 latitude, bytes32 longitude, bytes32  currency, bytes32 ticketeerName]
        uint256[2] event_times; // -> [uin256 startingTime, uint256 endingTime]
        bool set_aside; // -> false = default
        // bytes[] extra_data;
        bytes32[] extra_data;
        bool private_event;
    }

    mapping(address => EventStruct) private allEventStructs;

    address[] public eventAddresses;  

    bytes32 private constant FACTORY_ROLE = keccak256("FACTORY_ROLE");
    bytes32 private constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    event newEventRegistered(
      address indexed eventAddress,
      uint256 indexed getUsed,
      string eventName,
      uint256 indexed orderTime
    );

    event AccessControlSet(
      address indexed NewAccesscontrol
    );

    event UnderWriterSet(
      address indexed eventAddress,
      address indexed underWriterAddress
    );

    // TODO change bouncer name
    function __initialize_metadata(
      address address_bouncer,
      address address_economics
      ) public initializer {
        GET_BOUNCER = IGETAccessControl(address_bouncer);
        ECONOMICS = IEconomicsGET(address_economics);
    }

    /**
     * @dev Throws if called by any account other than the GET Protocol admin account.
     */
    modifier onlyRelayer() {
        require(
            GET_BOUNCER.hasRole(RELAYER_ROLE, msg.sender), "CALLER_NOT_RELAYER");
        _;
    }
  
    /**
     * @dev Throws if called by any account other than the GET Protocol admin account.
     */
    modifier onlyAdmin() {
        require(
            GET_BOUNCER.hasRole(RELAYER_ROLE, msg.sender), "CALLER_NOT_ADMIN");
        _;
    }

    function setAccessControl(
      address newAddressBouncer
      ) external onlyAdmin {

        GET_BOUNCER = IGETAccessControl(newAddressBouncer);
        
        emit AccessControlSet(
          newAddressBouncer);
    }

    function setUnderwriterAddress(
      address eventAddress, 
      address wrappingContract
      ) external onlyAdmin {

        allEventStructs[eventAddress].underwriter_address = wrappingContract;

        emit UnderWriterSet(
          eventAddress, 
          wrappingContract
        );
    }

    function registerEvent(
      address eventAddress,
      address integratorAccountPublicKeyHash,
      string memory eventName, 
      string memory shopUrl,
      string memory imageUrl,
      bytes32[4] memory eventMeta, // -> [bytes32 latitude, bytes32 longitude, bytes32  currency, bytes32 ticketeerName]
      uint256[2] memory eventTimes, // -> [uin256 startingTime, uint256 endingTime]
      bool setAside, // -> false = default
      // bytes[] memory extraData
      bytes32[] memory extraData,
      bool isPrivate
      ) public onlyRelayer {

      address underwriterAddress = 0x0000000000000000000000000000000000000000;

      allEventStructs[eventAddress] = EventStruct(
        eventAddress, 
        integratorAccountPublicKeyHash,
        underwriterAddress,
        eventName, 
        shopUrl,
        imageUrl,
        eventMeta, 
        eventTimes, 
        setAside,
        extraData,
        isPrivate
      );

      eventAddresses.push(eventAddress);

      emit newEventRegistered(
        eventAddress,
        20000,
        eventName,
        block.timestamp
      );
    
    }

    function getUnderwriterAddress(
      address eventAddress
      ) public virtual view returns (
        address underWriterAddress
      )
      {
        underWriterAddress = allEventStructs[eventAddress].underwriter_address;
      }

    function isInventoryUnderwritten(
      address eventAddress)
        public virtual view 
        returns (
          bool is_set_aside
        )
        {
          is_set_aside = allEventStructs[eventAddress].set_aside;
        }

    function getEventData(
      address eventAddress)
        public virtual view
        returns (
          address _integrator_address,
          address _underwriter_address,
          string memory _event_name,
          string memory _shop_url,
          string memory _image_url,
          bytes32[4] memory _event_meta,
          uint256[2] memory _event_times,
          bool _set_aside,
          bytes32[] memory _extra_data,
          bool _private_event
          )    
        {
          EventStruct storage mdata = allEventStructs[eventAddress];
          _integrator_address = mdata.integrator_address;
          _underwriter_address = mdata.underwriter_address;
          _event_name = mdata.event_name;
          _shop_url = mdata.shop_url;
          _image_url = mdata.image_url;
          _event_meta = mdata.event_metadata;
          _event_times = mdata.event_times;
          _set_aside = mdata.set_aside;
          _extra_data = mdata.extra_data;
          _private_event = mdata.private_event;
      }

    function getEventCount() public view returns(uint256 eventCount) 
    {
      eventCount = eventAddresses.length;
    }

}