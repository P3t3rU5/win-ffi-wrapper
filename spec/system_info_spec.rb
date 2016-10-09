require 'rspec'
require_relative '../test/test_helper'
require 'win-ffi-wrapper/system_info'

include WinFFIWrapper

describe SystemInfo do

  describe 'get_computer_name' do
    it 'should return DASP-SIDE' do
      expect(SystemInfo.get_computer_name).to eq 'DASP-SIDE'
    end
  end

  describe 'expand_environment_string' do
    it 'should expand environment variables' do
      expect(SystemInfo.expand_environment_string('%OS%')).to eq 'Windows_NT'
    end

    it 'should not expand' do
      expect(SystemInfo.expand_environment_string('%BLABLABLA%')).to eq '%BLABLABLA%'
    end
  end

  describe 'get_system_directory' do
    it 'should be C:\WINDOWS\system32' do
      expect(SystemInfo.get_system_directory).to eq 'C:\WINDOWS\system32'
    end
  end

  describe 'get_system_windows_directory' do
    it 'should be C:\WINDOWS' do
      expect(SystemInfo.get_system_windows_directory).to eq 'C:\WINDOWS'
    end
  end

  describe 'get_windows_directory' do
    it 'should be C:\WINDOWS' do
      expect(SystemInfo.get_windows_directory).to eq 'C:\WINDOWS'
    end
  end

  describe 'get_systemwow64_directory' do
    it 'should be C:\WINDOWS\SysWoW64' do
      expect(SystemInfo.get_systemwow64_directory).to eq 'C:\WINDOWS\SysWoW64'
    end
  end

  describe 'query_performance_counter' do
    it 'should return ' do
      expect(SystemInfo.query_performance_counter).to be > 0
    end
  end

  describe 'query_performance_counter' do
    it 'should return the frequency of the clock' do
      expect(SystemInfo.query_performance_frequency).to be > 0
    end
  end

  describe 'query_performance' do
    it 'should calculate the performance' do
      expect(SystemInfo.query_performance).to be >0
    end
  end

  describe 'get_product_info' do
    it 'should return the product type' do
      expect(SystemInfo.get_product_info).to eq :PROFESSIONAL
    end
  end

  describe 'get_firmaware_type' do
    it 'should be Uefi' do
      expect(SystemInfo.get_firmaware_type).to eq :Uefi
    end
  end

  describe 'is_native_vhd_boot' do
    it '' do
      expect(SystemInfo.is_native_vhd_boot).to be false
    end
  end

end