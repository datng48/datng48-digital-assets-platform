import React, { useEffect, useState } from 'react';
import { Button, Table, message, Upload, Modal, Form, Input, Tabs, Radio, Tag } from 'antd';
import { ReloadOutlined, UploadOutlined, DollarOutlined, DownloadOutlined, LoginOutlined, UserAddOutlined, CheckCircleOutlined } from '@ant-design/icons';
import { assets, purchases, auth, earnings } from './services/api';

interface Asset {
  id: number;
  title: string;
  description: string;
  file_url: string;
  price: number | string;
  creator_name: string;
  creator_id: number;
  purchased?: boolean;
}

interface LoginForm {
  email: string;
  password: string;
}

interface RegisterForm extends LoginForm {
  name: string;
  role: 'customer' | 'creator' | 'admin';
  password_confirmation?: string;
  admin_code?: string;
}

interface CreatorEarnings {
  creator_id: number;
  total_earnings: number;
}

function App() {
  const [assetList, setAssetList] = useState<Asset[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedAsset, setSelectedAsset] = useState<Asset | null>(null);
  const [purchaseModalVisible, setPurchaseModalVisible] = useState(false);
  const [successModalVisible, setSuccessModalVisible] = useState(false);
  const [authModalVisible, setAuthModalVisible] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userName, setUserName] = useState<string>('');
  const [userRole, setUserRole] = useState<string>('');
  const [creatorEarnings, setCreatorEarnings] = useState<CreatorEarnings[]>([]);
  const [form] = Form.useForm<RegisterForm>();

  useEffect(() => {
    loadAssets();
    const token = localStorage.getItem('token');
    const role = localStorage.getItem('userRole');
    const name = localStorage.getItem('userName');
    if (token) {
      setIsLoggedIn(true);
      if (name) setUserName(name);
      if (role) {
        setUserRole(role);
        if (role === 'admin') {
          loadCreatorEarnings();
        }
      }
    }
  }, []);

  const loadAssets = async () => {
    try {
      setLoading(true);
      
      const token = localStorage.getItem('token');
      const isUserLoggedIn = !!token;
      
      const response = await assets.list();
      let assetsList = response.data;
      
      if (isUserLoggedIn) {
        try {
          const purchasedResponse = await purchases.purchased();
          const purchasedAssets = purchasedResponse.data;
          
          const purchasedAssetIds = purchasedAssets.map((asset: Asset) => asset.id);
          
          assetsList = assetsList.map((asset: Asset) => {
            const isPurchased = purchasedAssetIds.includes(asset.id);
            if (isPurchased) {
              return { ...asset, purchased: true };
            }
            return asset;
          });
        } catch (err) {
          console.error('Error fetching purchased assets:', err);
        }
      }
      
      setAssetList(assetsList);
    } catch (error) {
      message.error('Failed to load assets');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const loadCreatorEarnings = async () => {
    try {
      const response = await earnings.getCreatorEarnings();
      setCreatorEarnings(response.data);
    } catch (error) {
      console.error('Failed to load earnings:', error);
      message.error('Failed to load creator earnings');
    }
  };

  const handleLogin = async (values: LoginForm) => {
    try {
      const response = await auth.login(values);
      const { token, user } = response.data;
      localStorage.setItem('token', token);
      localStorage.setItem('userRole', user.role);
      localStorage.setItem('userName', user.name);
      localStorage.setItem('userEmail', user.email);
      localStorage.setItem('userId', user.id.toString());
      setUserName(user.name);
      setUserRole(user.role);
      setIsLoggedIn(true);
      setAuthModalVisible(false);
      message.success('Logged in successfully');
      loadAssets();
    } catch (error) {
      message.error('Login failed');
      console.error(error);
    }
  };

  const handleRegister = async (values: RegisterForm) => {
    try {
      if (values.password !== values.password_confirmation) {
        message.error('Password do not match');
        return;
      }
      
      const { password_confirmation, ...registrationData } = values;

      if (registrationData.admin_code) {
        registrationData.role = 'admin';
      }

      const response = await auth.register(registrationData);
      const { token, user } = response.data;
      localStorage.setItem('token', token);
      localStorage.setItem('userRole', user.role);
      localStorage.setItem('userName', user.name);
      localStorage.setItem('userEmail', user.email);
      localStorage.setItem('userId', user.id.toString());
      setUserName(user.name);
      setUserRole(user.role);
      setIsLoggedIn(true);
      setAuthModalVisible(false);
      message.success('Registered successfully');
    } catch (error: any) {
      if (error.response?.status === 400) {
        message.error(error.response.data.error);
      } else if (error.response?.status === 422) {
        const errors = error.response.data.errors;
        if (Array.isArray(errors)) {
          errors.forEach(err => message.error(err));
        } else {
          message.error('Registration failed. Please check your information.');
        }
      } else {
        message.error('Registration failed. Please try again.');
      }
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('userRole');
    localStorage.removeItem('userName');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userId');
    setUserName('');
    setUserRole('');
    setIsLoggedIn(false);
    loadAssets();
    message.success('Logged out successfully');
  };

  const handleBulkUpload = async (file: File) => {
    try {
      const fileContent = await new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target?.result as string);
        reader.readAsText(file);
      });

      await assets.bulkImport({ assets: fileContent });
      message.success('Assets imported successfully');
      loadAssets();
    } catch (error) {
      message.error('Failed to import assets');
      console.error(error);
    }
    return false; 
  };

  const handlePurchase = async (asset: Asset) => {
    if (!isLoggedIn) {
      setAuthModalVisible(true);
      return;
    }

    try {
      const response = await purchases.create({ asset_id: asset.id });
      
      const { asset: purchasedAsset } = response.data;
      
      setAssetList(prevList => 
        prevList.map(item => 
          item.id === purchasedAsset.id 
            ? { ...item, purchased: true }
            : item
        )
      );
      
      setPurchaseModalVisible(false);
      setSuccessModalVisible(true);
      setSelectedAsset({ ...asset, purchased: true });
      message.success('Purchase successful!');

      loadAssets();
      
      if (userRole === 'admin') {
        loadCreatorEarnings();
      }
    } catch (error: any) {
      
      if (error.response?.data?.asset?.purchased) {
        const { asset: purchasedAsset } = error.response.data;
        setAssetList(prevList => 
          prevList.map(item => 
            item.id === purchasedAsset.id 
              ? { ...item, purchased: true }
              : item
          )
        );
        
        setPurchaseModalVisible(false);
        
        if (selectedAsset && selectedAsset.id === purchasedAsset.id) {
          setSelectedAsset({ ...selectedAsset, purchased: true });
        }
        
        loadAssets();
        
        message.info('You already purchased this asset');
      } else {
        message.error('Fialed to complete purchase, try again');
      }
    }
  };

  const handleRefreshEarnings = () => {
    if (userRole === 'admin') {
      loadCreatorEarnings();
    }
  };

  const formatPrice = (price: number | string): string => {
    const numericPrice = typeof price === 'string' ? parseFloat(price) : price;
    return !isNaN(numericPrice) ? `$${numericPrice.toFixed(2)}` : '$0.00';
  };

  const columns = [
    {
      title: 'Title',
      dataIndex: 'title',
      key: 'title',
    },
    {
      title: 'Description',
      dataIndex: 'description',
      key: 'description',
    },
    {
      title: 'Price',
      dataIndex: 'price',
      key: 'price',
      render: (price: number | string) => formatPrice(price),
    },
    {
      title: 'File URL',
      dataIndex: 'file_url',
      key: 'file_url',
      render: (url: string) => (
        <a href={url} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800">
          {url}
        </a>
      ),
    },
    {
      title: 'Creator',
      dataIndex: 'email',
      key: 'email',
    },
    ...(userRole === 'customer' ? [{
      title: 'Actions',
      key: 'actions',
      render: (_: any, record: Asset) => (
        <div className="space-x-2">
          {record.purchased ? (
            <Button
              type="primary"
              icon={<DownloadOutlined />}
              href={record.file_url}
              target="_blank"
              style={{ backgroundColor: '#52c41a', borderColor: '#52c41a' }}
              className="hover:bg-green-600 hover:border-green-600"
            >
              Download
            </Button>
          ) : (
            <Button
              type="primary"
              icon={<DollarOutlined />}
              onClick={() => {
                if (!isLoggedIn) {
                  setAuthModalVisible(true);
                  return;
                }
                setSelectedAsset(record);
                setPurchaseModalVisible(true);
              }}
              style={{ backgroundColor: '#1890ff', borderColor: '#1890ff' }}
              className="hover:bg-blue-600 hover:border-blue-600"
            >
              Purchase
            </Button>
          )}
        </div>
      ),
    }] : []),
  ];

  const authItems = [
    {
      key: 'login',
      label: 'Login',
      children: (
        <Form name="login" onFinish={handleLogin}>
          <Form.Item
            name="email"
            rules={[{ required: true, message: 'Please input your email!' }]}
          >
            <Input prefix={<UserAddOutlined />} placeholder="Email" />
          </Form.Item>
          <Form.Item
            name="password"
            rules={[{ required: true, message: 'Please input your password!' }]}
          >
            <Input.Password placeholder="Password" />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" block>
              Log in
            </Button>
          </Form.Item>
        </Form>
      ),
    },
    {
      key: 'register',
      label: 'Register',
      children: (
        <Form 
          name="register" 
          onFinish={handleRegister}
          onValuesChange={(changedValues: Partial<RegisterForm>, allValues: RegisterForm) => {
            if ('admin_code' in changedValues) {
              const adminCode = changedValues.admin_code;
              if (adminCode) {
                form.setFieldsValue({ role: 'admin' });
              }
            }
          }}
          form={form}
        >
          <Form.Item
            name="email"
            rules={[
              { required: true, message: 'Please input your email!' },
              { type: 'email', message: 'Please enter a valid email!' }
            ]}
          >
            <Input prefix={<UserAddOutlined />} placeholder="Email" />
          </Form.Item>
          <Form.Item
            name="name"
            rules={[{ required: true, message: 'Please input your name!' }]}
          >
            <Input placeholder="Name" />
          </Form.Item>
          <Form.Item
            name="password"
            rules={[{ required: true, message: 'Please input your password!' }]}
          >
            <Input.Password placeholder="Password" />
          </Form.Item>
          <Form.Item
            name="password_confirmation"
            rules={[
              { required: true, message: 'Please confirm your password!' },
              ({ getFieldValue }) => ({
                validator(_, value) {
                  if (!value || getFieldValue('password') === value) {
                    return Promise.resolve();
                  }
                  return Promise.reject(new Error('The passwords do not match!'));
                },
              }),
            ]}
          >
            <Input.Password placeholder="Confirm Password" />
          </Form.Item>
          <Form.Item
            name="admin_code"
          >
            <Input placeholder="Admin Code (Optional)" />
          </Form.Item>
          <Form.Item
            name="role"
            initialValue="customer"
            rules={[
              { required: true, message: 'Please select a role!' }
            ]}
          >
            <Radio.Group>
              <Radio.Button value="customer">Customer</Radio.Button>
              <Radio.Button value="creator">Creator</Radio.Button>
            </Radio.Group>
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" block>
              Register
            </Button>
          </Form.Item>
        </Form>
      ),
    },
  ];

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold text-blue-600">
            Digital Assets Platform
          </h1>
          {isLoggedIn ? (
            <div className="flex items-center space-x-4">
              <span className="text-gray-700">
                Welcome, {userName} 
                <Tag color={userRole === 'creator' ? 'blue' : userRole === 'admin' ? 'red' : 'green'}>
                  {userRole}
                </Tag>
              </span>
              <Button onClick={handleLogout}>Logout</Button>
            </div>
          ) : (
            <Button type="primary" icon={<LoginOutlined />} onClick={() => setAuthModalVisible(true)}>
              Login / Register
            </Button>
          )}
        </div>

        {userRole === 'admin' && (
          <div className="bg-white rounded-lg shadow-lg p-6 mb-8">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-2xl font-semibold">Creator Earnings Dashboard</h2>
              <Button 
                type="primary"
                icon={<ReloadOutlined />}
                onClick={handleRefreshEarnings}
              >
                Refresh Earnings
              </Button>
            </div>
            <Table
              dataSource={creatorEarnings}
              columns={[
                {
                  title: 'Creator Name',
                  dataIndex: 'name',
                  key: 'name',
                },
                 {
                  title: 'Creator Email',
                  dataIndex: 'email',
                  key: 'email',
                },
                {
                  title: 'Total Earnings',
                  dataIndex: 'total_earnings',
                  key: 'total_earnings',
                  render: (earnings: number) => formatPrice(earnings),
                  sorter: (a: CreatorEarnings, b: CreatorEarnings) => a.total_earnings - b.total_earnings,
                },
              ]}
              rowKey="creator_id"
              pagination={false}
            />
          </div>
        )}
        
        {userRole !== 'admin' && (
        <div className="bg-white rounded-lg shadow-lg p-6">
          <div className="mb-4 flex justify-between items-center">
            <div className="space-x-2">
              <Button 
                type="primary"
                icon={<ReloadOutlined />}
                onClick={loadAssets}
                loading={loading}
              >
                Refresh
              </Button>
              {isLoggedIn && userRole === 'creator' && (
                <Upload
                  accept=".json"
                  showUploadList={false}
                  beforeUpload={handleBulkUpload}
                >
                  <Button icon={<UploadOutlined />}>Bulk Import</Button>
                </Upload>
              )}
            </div>
          </div>
          <Table
            dataSource={assetList}
            columns={columns}
            loading={loading}
            rowKey="id"
          />
        </div> )}
      </div>

      <Modal
        title="Confirm Purchase"
        open={purchaseModalVisible}
        onOk={() => selectedAsset && handlePurchase(selectedAsset)}
        onCancel={() => setPurchaseModalVisible(false)}
        okText="Purchase"
        cancelText="Cancel"
        okButtonProps={{ 
          style: { backgroundColor: '#1890ff', borderColor: '#1890ff' }
        }}
      >
        {selectedAsset && (
          <p>
            Are you sure you want to purchase "{selectedAsset.title}" for {formatPrice(selectedAsset.price)}?
          </p>
        )}
      </Modal>

      <Modal
        title="Purchase Successful"
        open={successModalVisible}
        onOk={() => setSuccessModalVisible(false)}
        onCancel={() => setSuccessModalVisible(false)}
        footer={[
          <Button
            key="download"
            type="primary"
            icon={<DownloadOutlined />}
            href={selectedAsset?.file_url}
            target="_blank"
            style={{ backgroundColor: '#52c41a', borderColor: '#52c41a' }}
            className="hover:bg-green-600 hover:border-green-600"
          >
            Download Now
          </Button>
        ]}
      >
        <div className="text-center py-4">
          <CheckCircleOutlined className="text-5xl text-green-500 mb-4" />
          <p className="text-lg mb-2">Purchase Successful!</p>
          <p>You can now download your asset.</p>
        </div>
      </Modal>

      <Modal
        title="Authentication"
        open={authModalVisible}
        onCancel={() => setAuthModalVisible(false)}
        footer={null}
        width={400}
      >
        <Tabs items={authItems} />
      </Modal>
    </div>
  );
}

export default App;

